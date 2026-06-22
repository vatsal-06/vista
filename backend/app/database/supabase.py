import logging
from typing import Dict, Any, List, Optional
from supabase import create_client, Client
from app.core.config import settings

logger = logging.getLogger("supabase_client")

class MockSupabaseClient:
    """
    A robust in-memory mock client that mirrors the basic database APIs of supabase-py.
    This ensures the backend is fully functional even if no active Supabase credentials are provided.
    """
    def __init__(self):
        self._store: Dict[str, List[Dict[str, Any]]] = {
            "users": [],
            "user_preferences": [],
            "routes": [],
            "landmarks": [],
            "walk_sessions": [],
            "hazards": [],
            "community_reports": [],
            "emergency_contacts": [],
            "emergency_events": [],
            "memory_embeddings": []
        }
        logger.info("Initializing Mock Supabase Client (In-Memory Database active).")

    class TableQuery:
        def __init__(self, table_name: str, store: Dict[str, List[Dict[str, Any]]]):
            self.table_name = table_name
            self.store = store
            self.data = list(store.get(table_name, []))

        def insert(self, data: Any):
            if isinstance(data, list):
                for item in data:
                    self.store[self.table_name].append(item)
                return self
            else:
                self.store[self.table_name].append(data)
                self._current_result = data
                return self

        def select(self, *columns: str):
            # In a simplified mock, select returns everything. We can filter if needed.
            return self

        def update(self, data: Any):
            # Update key-value pairs of matched data elements
            for item in self.data:
                item.update(data)
            self._current_result = self.data
            return self

        def eq(self, column: str, value: Any):
            self.data = [item for item in self.data if item.get(column) == value]
            return self

        def filter(self, column: str, operator: str, value: Any):
            # Basic filter support
            if operator == "eq":
                self.data = [item for item in self.data if item.get(column) == value]
            return self

        def execute(self):
            # For compatibility with older supabase-py versions or raw response structure
            class MockResponse:
                def __init__(self, data):
                    self.data = data
            
            # If inserting, return the inserted item
            if hasattr(self, '_current_result'):
                return MockResponse(self._current_result)
            return MockResponse(self.data)

        # Allow chaining properties for direct access
        @property
        def data(self):
            return self._data
        
        @data.setter
        def data(self, val):
            self._data = val

    def table(self, table_name: str) -> TableQuery:
        return self.TableQuery(table_name, self._store)

# Initialize Client
supabase_client: Any = None

try:
    if "placeholder" not in settings.SUPABASE_URL and "placeholder" not in settings.SUPABASE_KEY:
        supabase_client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        logger.info("Supabase client initialized successfully.")
    else:
        logger.warning("Placeholder Supabase credentials detected. Falling back to MockSupabaseClient.")
        supabase_client = MockSupabaseClient()
except Exception as e:
    logger.error(f"Error initializing Supabase client: {e}. Falling back to MockSupabaseClient.")
    supabase_client = MockSupabaseClient()

def get_db():
    """
    Dependency helper to retrieve the active database client.
    """
    return supabase_client
