import logging
from typing import List, Dict, Any, Optional
from app.database.supabase import get_db
from app.core.config import settings

logger = logging.getLogger("memory_service")

# Try importing google-generativeai for embeddings
try:
    import google.generativeai as genai
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False

class MemoryService:
    def __init__(self):
        self.db = get_db()
        self.embeddings_model = "models/embedding-001"
        self.gemini_ready = HAS_GEMINI and settings.GEMINI_API_KEY is not None

    def get_embedding(self, text: str) -> Optional[List[float]]:
        """
        Generates 1536-dimensional vector embedding of text using Gemini API.
        Falls back to None if not configured.
        """
        if not self.gemini_ready:
            # Return dummy 1536-dimensional vector
            return [0.0] * 1536
            
        try:
            genai.configure(api_key=settings.GEMINI_API_KEY)
            result = genai.embed_content(
                model=self.embeddings_model,
                content=text,
                task_type="retrieval_document"
            )
            embedding = result.get("embedding", [])
            # Pad or trim to 1536 elements if necessary
            if len(embedding) < 1536:
                embedding.extend([0.0] * (1536 - len(embedding)))
            return embedding[:1536]
        except Exception as e:
            logger.error(f"Error generating embedding via Gemini: {e}")
            return [0.0] * 1536

    def save_memory(self, user_id: str, content: str) -> Dict[str, Any]:
        """
        Saves a text memory and its vector embedding to the database.
        """
        embedding = self.get_embedding(content)
        data = {
            "user_id": user_id,
            "content": content,
            "embedding": embedding
        }
        
        try:
            # Write to Supabase/Mock db
            res = self.db.table("memory_embeddings").insert(data).execute()
            return {"success": True, "data": res.data}
        except Exception as e:
            logger.error(f"Failed to save memory to database: {e}")
            return {"success": False, "error": str(e)}

    def search_memories(self, user_id: str, query: str, limit: int = 3) -> List[Dict[str, Any]]:
        """
        Searches user memories using semantic search (vector cosine similarity).
        If database does not support vector RPC, falls back to text substring matching.
        """
        query_vector = self.get_embedding(query)
        
        try:
            # In a real Supabase/PostgreSQL pgvector setup, we invoke an RPC function:
            # CREATE OR REPLACE FUNCTION match_memories(query_embedding vector(1536), match_threshold float, match_count int, filter_user_id uuid)
            # RETURNS TABLE (id uuid, content text, similarity float) ...
            
            # We first try to call the pgvector RPC
            rpc_res = self.db.rpc(
                "match_memories", 
                {
                    "query_embedding": query_vector, 
                    "match_threshold": 0.5, 
                    "match_count": limit,
                    "filter_user_id": user_id
                }
            ).execute()
            return rpc_res.data
        except Exception:
            # Fallback to direct client table query with standard string search (in-memory substring filter)
            try:
                res = self.db.table("memory_embeddings").select("id", "content").eq("user_id", user_id).execute()
                all_memories = res.data if hasattr(res, "data") else res
                if not isinstance(all_memories, list):
                    all_memories = []
                
                # Basic mock query ranking: check matching words
                query_words = set(query.lower().split())
                ranked = []
                for m in all_memories:
                    content = m.get("content", "")
                    content_words = set(content.lower().split())
                    common = query_words.intersection(content_words)
                    score = len(common) / max(1, len(query_words))
                    ranked.append((score, m))
                
                # Sort by score descending and return limit
                ranked.sort(key=lambda x: x[0], reverse=True)
                return [item[1] for item in ranked[:limit]]
            except Exception as e:
                logger.error(f"Memory fallback search failed: {e}")
                return []

memory_service = MemoryService()
