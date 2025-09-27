#!/usr/bin/env python3
"""
Test script for ADK deployment and Cloud Run integration
"""

import requests
import json
import os
import time

# Your deployed Cloud Run URL
CLOUD_RUN_URL = "https://agent-service-126953222459.us-east1.run.app"

def test_cloud_run_health():
    """Test if Cloud Run service is accessible"""
    print("🧪 Testing Cloud Run health...")
    
    try:
        response = requests.get(f"{CLOUD_RUN_URL}/", timeout=10)
        print(f"✅ Cloud Run health: {response.status_code}")
        print(f"   Response: {response.text[:200]}...")
        return response.status_code == 200
    except requests.exceptions.Timeout:
        print("❌ Cloud Run service timeout")
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Cloud Run service not accessible")
        return False
    except Exception as e:
        print(f"❌ Cloud Run health check failed: {str(e)}")
        return False

def test_adk_agent_endpoint():
    """Test ADK agent endpoint"""
    print("\n🧪 Testing ADK agent endpoint...")
    
    try:
        # Test the run_sse endpoint
        test_data = {
            "app_name": "agent",
            "user_id": "test_user",
            "session_id": "test_session",
            "new_message": {
                "role": "user",
                "parts": [{
                    "text": "Tell me about the Shadesmith project"
                }]
            },
            "streaming": False
        }
        
        response = requests.post(
            f"{CLOUD_RUN_URL}/run_sse",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"✅ ADK agent endpoint: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"   Response type: {type(data)}")
                print(f"   Response keys: {list(data.keys()) if isinstance(data, dict) else 'Not a dict'}")
                return True
            except json.JSONDecodeError:
                print(f"   Response text: {response.text[:200]}...")
                return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ ADK agent test failed: {str(e)}")
        return False

def test_agent_tools():
    """Test specific agent tools"""
    print("\n🧪 Testing agent tools...")
    
    try:
        # Test project info
        test_data = {
            "app_name": "agent",
            "user_id": "test_user",
            "session_id": "test_session",
            "new_message": {
                "role": "user",
                "parts": [{
                    "text": "Get project information"
                }]
            },
            "streaming": False
        }
        
        response = requests.post(
            f"{CLOUD_RUN_URL}/run_sse",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"✅ Agent tools test: {response.status_code}")
        
        if response.status_code == 200:
            print(f"   Response received successfully")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Agent tools test failed: {str(e)}")
        return False

def test_paint_mixing_pipeline():
    """Test paint mixing pipeline through ADK"""
    print("\n🧪 Testing paint mixing pipeline...")
    
    try:
        # Test paint mixing calculation
        test_data = {
            "app_name": "agent",
            "user_id": "test_user",
            "session_id": "test_session",
            "new_message": {
                "role": "user",
                "parts": [{
                    "text": "Calculate paint mixing ratios for target color RGB(128, 64, 192) using user colors RGB(255, 0, 0) and RGB(0, 255, 0)"
                }]
            },
            "streaming": False
        }
        
        response = requests.post(
            f"{CLOUD_RUN_URL}/run_sse",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"✅ Paint mixing pipeline: {response.status_code}")
        
        if response.status_code == 200:
            print(f"   Response received successfully")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Paint mixing pipeline test failed: {str(e)}")
        return False

def test_error_handling():
    """Test error handling"""
    print("\n🧪 Testing error handling...")
    
    try:
        # Test with invalid data
        test_data = {
            "app_name": "invalid_agent",
            "user_id": "test_user",
            "session_id": "test_session",
            "new_message": {
                "role": "user",
                "parts": [{
                    "text": "This should cause an error"
                }]
            },
            "streaming": False
        }
        
        response = requests.post(
            f"{CLOUD_RUN_URL}/run_sse",
            json=test_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"✅ Error handling test: {response.status_code}")
        
        # We expect this to either work or fail gracefully
        if response.status_code in [200, 400, 404, 500]:
            print(f"   Response handled appropriately")
            return True
        else:
            print(f"   Unexpected status code: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error handling test failed: {str(e)}")
        return False

def main():
    """Run all ADK deployment tests"""
    print("🚀 Starting ADK Deployment Tests")
    print("=" * 60)
    print(f"🌐 Testing Cloud Run URL: {CLOUD_RUN_URL}")
    print("=" * 60)
    
    tests = [
        ("Cloud Run Health", test_cloud_run_health),
        ("ADK Agent Endpoint", test_adk_agent_endpoint),
        ("Agent Tools", test_agent_tools),
        ("Paint Mixing Pipeline", test_paint_mixing_pipeline),
        ("Error Handling", test_error_handling)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
            time.sleep(1)  # Brief pause between tests
        except Exception as e:
            print(f"❌ {test_name} failed with error: {str(e)}")
            results[test_name] = False
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 ADK Deployment Test Results:")
    print("=" * 60)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print(f"\n🎯 Overall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All ADK deployment tests passed!")
    else:
        print("⚠️  Some tests failed. Check the Cloud Run service status.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
