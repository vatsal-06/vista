import sys
import os

# Ensure the backend directory is in the path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
import test_api

print("Saath Chalo Backend Verification - Manual Test Execution")
print("=======================================================")

try:
    print("1. Running test_root...")
    test_api.test_root()
    print("   -> PASSED")
    
    print("2. Running test_walk_workflow...")
    test_api.test_walk_workflow()
    print("   -> PASSED")
    
    print("3. Running test_ai_ask...")
    test_api.test_ai_ask()
    print("   -> PASSED")
    
    print("4. Running test_emergency_sos...")
    test_api.test_emergency_sos()
    print("   -> PASSED")
    
    print("\n=======================================================")
    print("STATUS: ALL TESTS PASSED SUCCESSFULLY!")
    sys.exit(0)
except Exception as e:
    print(f"\nSTATUS: TEST SUITE ENCOUNTERED A FAILURE: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
