#!/usr/bin/env python3
"""
Test script for database agent functionality
Tests all CRUD operations without requiring actual Firestore connection
"""

import json
from agent.database_agent import (
    save_color_to_inventory,
    get_user_inventory,
    save_mixing_result,
    get_mixing_history,
    create_user_profile
)

def test_database_operations():
    """Test all database operations with mock data"""
    print("🧪 Testing Database Agent Operations")
    print("=" * 50)
    
    test_user_id = "demo_user_123"
    
    # Test 1: Create User Profile
    print("\n1️⃣ Testing User Profile Creation...")
    profile_data = {
        "displayName": "Demo User",
        "email": "demo@shadesmith.com",
        "preferences": {
            "default_color_format": "rgb",
            "theme": "dark",
            "notifications": True
        }
    }
    
    result = create_user_profile(test_user_id, profile_data)
    print(f"✅ Profile Creation: {result.get('success', False)}")
    if not result.get('success'):
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    # Test 2: Save Color to Inventory
    print("\n2️⃣ Testing Color Save...")
    color_data = {
        "name": "Ocean Blue",
        "rgb": {"r": 0, "g": 119, "b": 190},
        "hex": "#0077BE",
        "cmyk": {"c": 100, "m": 37, "y": 0, "k": 25},
        "source": "manual_entry",
        "tags": ["blue", "ocean", "primary"]
    }
    
    result = save_color_to_inventory(test_user_id, color_data)
    print(f"✅ Color Save: {result.get('success', False)}")
    if not result.get('success'):
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    # Test 3: Save Another Color
    print("\n3️⃣ Testing Second Color Save...")
    color_data2 = {
        "name": "Sunset Orange",
        "rgb": {"r": 255, "g": 140, "b": 0},
        "hex": "#FF8C00",
        "cmyk": {"c": 0, "m": 45, "y": 100, "k": 0},
        "source": "color_picker",
        "tags": ["orange", "sunset", "warm"]
    }
    
    result = save_color_to_inventory(test_user_id, color_data2)
    print(f"✅ Second Color Save: {result.get('success', False)}")
    if not result.get('success'):
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    # Test 4: Get User Inventory
    print("\n4️⃣ Testing Inventory Retrieval...")
    result = get_user_inventory(test_user_id, limit=10)
    print(f"✅ Inventory Retrieval: {result.get('success', False)}")
    if result.get('success'):
        print(f"   Colors found: {result.get('total_colors', 0)}")
    else:
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    # Test 5: Save Mixing Result
    print("\n5️⃣ Testing Mixing Result Save...")
    mixing_data = {
        "user_colors": [
            {"r": 0, "g": 119, "b": 190},  # Ocean Blue
            {"r": 255, "g": 140, "b": 0}   # Sunset Orange
        ],
        "target_rgb": {"r": 128, "g": 130, "b": 95},
        "result_rgb": {"r": 125, "g": 128, "b": 92},
        "mixing_ratios": [0.6, 0.4],
        "accuracy": {
            "distance": 5.2,
            "level": "Excellent"
        },
        "success": True
    }
    
    result = save_mixing_result(test_user_id, mixing_data)
    print(f"✅ Mixing Result Save: {result.get('success', False)}")
    if not result.get('success'):
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    # Test 6: Get Mixing History
    print("\n6️⃣ Testing Mixing History Retrieval...")
    result = get_mixing_history(test_user_id, limit=5)
    print(f"✅ Mixing History: {result.get('success', False)}")
    if result.get('success'):
        print(f"   Mixing results found: {result.get('total_results', 0)}")
    else:
        print(f"   Error: {result.get('error', 'Unknown error')}")
    
    print("\n" + "=" * 50)
    print("🎯 Database Agent Test Complete!")
    print("\nNote: These tests show the function structure and error handling.")
    print("For full functionality, Firestore database needs to be set up.")

if __name__ == "__main__":
    test_database_operations()
