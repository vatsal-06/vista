import re
from datetime import datetime
from typing import Any, Dict

def clean_html_tags(text: str) -> str:
    """
    Remove HTML tags from strings (often returned from navigation steps).
    """
    return re.sub(r"<[^<]+?>", "", text)

def format_datetime_utc(dt: datetime) -> str:
    """
    Formats a datetime object to standard ISO UTC string representation.
    """
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")

def wrap_api_response(data: Any, message: str = "Success", success: bool = True) -> Dict[str, Any]:
    """
    Standard format for all API response payloads.
    """
    return {
        "success": success,
        "message": message,
        "data": data
    }
