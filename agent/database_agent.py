"""
Database Agent for Firestore operations
Handles saving and retrieving color data from Firebase Firestore
"""

import os
import json
import uuid
from datetime import datetime
from google.adk.agents import Agent
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
def initialize_firebase():
    """Initialize Firebase Admin SDK if not already initialized"""
    try:
        # Clear any existing apps to force reinitialization
        if firebase_admin._apps:
            for app_name, app in firebase_admin._apps.items():
                try:
                    firebase_admin.delete_app(app)
                    print(f"Deleted app: {app_name}")
                except Exception as e:
                    print(f"Error deleting app {app_name}: {e}")
        
        # Try to use Flutter app's service account key first
        flutter_key_path = os.path.join(os.path.dirname(__file__), '..', 'keys', 'shadesmith-b8de1.json')
        if os.path.exists(flutter_key_path):
            cred = credentials.Certificate(flutter_key_path)
            app = firebase_admin.initialize_app(cred, name='shadesmith-flutter')
            print("Using Flutter app's service account key")
        else:
            # Fall back to existing cloudvision key
            key_path = os.path.join(os.path.dirname(__file__), '..', 'keys', 'cloudvision.json')
            if os.path.exists(key_path):
                cred = credentials.Certificate(key_path)
                # Initialize with the Flutter app's project ID
                app = firebase_admin.initialize_app(cred, {
                    'projectId': 'shadesmith-b8de1'
                }, name='shadesmith-app')
                print("Using cloudvision key with shadesmith-b8de1 project")
            else:
                # Use default credentials (for Cloud Run)
                app = firebase_admin.initialize_app({
                    'projectId': 'shadesmith-b8de1'
                }, name='shadesmith-app')
                print("Using default credentials")
        
        return firestore.client(app=app)
    except Exception as e:
        print(f"Firebase initialization error: {e}")
        return None

def save_color_to_inventory(user_id: str, color_data: dict):
    """Save a color to user's inventory in Firestore"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Validate color data
        required_fields = ['name', 'rgb']
        if not all(field in color_data for field in required_fields):
            return {"success": False, "error": f"Missing required fields: {required_fields}"}
        
        # Generate unique ID for the color
        color_id = str(uuid.uuid4())
        
        # Prepare color document
        color_doc = {
            'id': color_id,
            'name': color_data.get('name', 'Unnamed Color'),
            'type': 'color',
            'rgb': color_data['rgb'],
            'hex': color_data.get('hex', f"#{color_data['rgb']['r']:02x}{color_data['rgb']['g']:02x}{color_data['rgb']['b']:02x}"),
            'cmyk': color_data.get('cmyk'),
            'addedAt': firestore.SERVER_TIMESTAMP,
            'source': color_data.get('source', 'manual'),
            'tags': color_data.get('tags', [])
        }
        
        # Save to Firestore
        doc_ref = db.collection('users').document(user_id).collection('inventory').document(color_id)
        doc_ref.set(color_doc)
        
        # Convert Firestore timestamps to strings for JSON serialization
        color_data_serializable = {
            'id': color_doc['id'],
            'name': color_doc['name'],
            'type': color_doc['type'],
            'rgb': color_doc['rgb'],
            'hex': color_doc['hex'],
            'cmyk': color_doc['cmyk'],
            'addedAt': 'Server Timestamp',
            'source': color_doc['source'],
            'tags': color_doc['tags']
        }
        
        return {
            "success": True,
            "message": f"Color '{color_data['name']}' saved successfully",
            "color_id": color_id,
            "color_data": color_data_serializable
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to save color: {str(e)}"
        }

def get_user_inventory(user_id: str, limit: int = 50):
    """Get all colors from user's inventory"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Query user's inventory
        inventory_ref = db.collection('users').document(user_id).collection('inventory')
        query = inventory_ref.order_by('addedAt', direction=firestore.Query.DESCENDING).limit(limit)
        docs = query.stream()
        
        colors = []
        for doc in docs:
            color_data = doc.to_dict()
            color_data['id'] = doc.id
            colors.append(color_data)
        
        return {
            "success": True,
            "message": f"Retrieved {len(colors)} colors from inventory",
            "user_id": user_id,
            "colors": colors,
            "total_colors": len(colors)
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to retrieve inventory: {str(e)}"
        }

def save_mixing_result(user_id: str, mixing_data: dict):
    """Save a paint mixing result to user's history"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Generate unique ID for the mixing result
        mixing_id = str(uuid.uuid4())
        
        # Prepare mixing document
        mixing_doc = {
            'id': mixing_id,
            'type': 'mixing_result',
            'user_colors': mixing_data.get('user_colors', []),
            'target_rgb': mixing_data.get('target_rgb', {}),
            'result_rgb': mixing_data.get('result_rgb', {}),
            'mixing_ratios': mixing_data.get('mixing_ratios', []),
            'accuracy': mixing_data.get('accuracy', {}),
            'createdAt': firestore.SERVER_TIMESTAMP,
            'success': mixing_data.get('success', False)
        }
        
        # Save to Firestore
        doc_ref = db.collection('users').document(user_id).collection('mixing_history').document(mixing_id)
        doc_ref.set(mixing_doc)
        
        # Convert Firestore timestamps to strings for JSON serialization
        mixing_data_serializable = {
            'id': mixing_doc['id'],
            'type': mixing_doc['type'],
            'user_colors': mixing_doc['user_colors'],
            'target_rgb': mixing_doc['target_rgb'],
            'result_rgb': mixing_doc['result_rgb'],
            'mixing_ratios': mixing_doc['mixing_ratios'],
            'accuracy': mixing_doc['accuracy'],
            'createdAt': 'Server Timestamp',
            'success': mixing_doc['success']
        }
        
        return {
            "success": True,
            "message": "Mixing result saved successfully",
            "mixing_id": mixing_id,
            "mixing_data": mixing_data_serializable
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to save mixing result: {str(e)}"
        }

def get_mixing_history(user_id: str, limit: int = 20):
    """Get user's mixing history"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Query user's mixing history
        history_ref = db.collection('users').document(user_id).collection('mixing_history')
        query = history_ref.order_by('createdAt', direction=firestore.Query.DESCENDING).limit(limit)
        docs = query.stream()
        
        history = []
        for doc in docs:
            mixing_data = doc.to_dict()
            mixing_data['id'] = doc.id
            history.append(mixing_data)
        
        return {
            "success": True,
            "message": f"Retrieved {len(history)} mixing results from history",
            "user_id": user_id,
            "mixing_history": history,
            "total_results": len(history)
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to retrieve mixing history: {str(e)}"
        }

def save_mixed_color_to_inventory(user_id: str, mixed_color_data: dict):
    """Save a mixed color to user's inventory"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Validate mixed color data
        required_fields = ['name', 'rgb', 'source_colors', 'mixing_ratios']
        if not all(field in mixed_color_data for field in required_fields):
            return {"success": False, "error": f"Missing required fields: {required_fields}"}
        
        # Generate unique ID for the mixed color
        mixed_color_id = str(uuid.uuid4())
        
        # Prepare mixed color document
        mixed_color_doc = {
            'id': mixed_color_id,
            'name': mixed_color_data.get('name', 'Mixed Color'),
            'type': 'mixed_color',
            'rgb': mixed_color_data['rgb'],
            'hex': mixed_color_data.get('hex', f"#{mixed_color_data['rgb']['r']:02x}{mixed_color_data['rgb']['g']:02x}{mixed_color_data['rgb']['b']:02x}"),
            'cmyk': mixed_color_data.get('cmyk'),
            'source_colors': mixed_color_data['source_colors'],
            'mixing_ratios': mixed_color_data['mixing_ratios'],
            'target_rgb': mixed_color_data.get('target_rgb'),
            'accuracy': mixed_color_data.get('accuracy'),
            'addedAt': firestore.SERVER_TIMESTAMP,
            'source': 'paint_mixing',
            'tags': mixed_color_data.get('tags', ['mixed', 'custom'])
        }
        
        # Save to Firestore
        doc_ref = db.collection('users').document(user_id).collection('inventory').document(mixed_color_id)
        doc_ref.set(mixed_color_doc)
        
        # Convert Firestore timestamps to strings for JSON serialization
        mixed_color_data_serializable = {
            'id': mixed_color_doc['id'],
            'name': mixed_color_doc['name'],
            'type': mixed_color_doc['type'],
            'rgb': mixed_color_doc['rgb'],
            'hex': mixed_color_doc['hex'],
            'cmyk': mixed_color_doc['cmyk'],
            'source_colors': mixed_color_doc['source_colors'],
            'mixing_ratios': mixed_color_doc['mixing_ratios'],
            'target_rgb': mixed_color_doc['target_rgb'],
            'accuracy': mixed_color_doc['accuracy'],
            'addedAt': 'Server Timestamp',
            'source': mixed_color_doc['source'],
            'tags': mixed_color_doc['tags']
        }
        
        return {
            "success": True,
            "message": f"Mixed color '{mixed_color_data['name']}' saved successfully",
            "mixed_color_id": mixed_color_id,
            "mixed_color_data": mixed_color_data_serializable
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to save mixed color: {str(e)}"
        }

def save_recipe_to_inventory(user_id: str, recipe_data: dict):
    """Save a paint mixing recipe to user's inventory"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Validate recipe data
        required_fields = ['name', 'source_colors', 'mixing_ratios', 'target_rgb']
        if not all(field in recipe_data for field in required_fields):
            return {"success": False, "error": f"Missing required fields: {required_fields}"}
        
        # Generate unique ID for the recipe
        recipe_id = str(uuid.uuid4())
        
        # Prepare recipe document
        recipe_doc = {
            'id': recipe_id,
            'name': recipe_data.get('name', 'Custom Recipe'),
            'type': 'recipe',
            'source_colors': recipe_data['source_colors'],
            'mixing_ratios': recipe_data['mixing_ratios'],
            'target_rgb': recipe_data['target_rgb'],
            'target_cmyk': recipe_data.get('target_cmyk'),
            'result_rgb': recipe_data.get('result_rgb'),
            'accuracy': recipe_data.get('accuracy'),
            'instructions': recipe_data.get('instructions', []),
            'addedAt': firestore.SERVER_TIMESTAMP,
            'source': 'paint_mixing',
            'tags': recipe_data.get('tags', ['recipe', 'custom'])
        }
        
        # Save to Firestore
        doc_ref = db.collection('users').document(user_id).collection('inventory').document(recipe_id)
        doc_ref.set(recipe_doc)
        
        # Convert Firestore timestamps to strings for JSON serialization
        recipe_data_serializable = {
            'id': recipe_doc['id'],
            'name': recipe_doc['name'],
            'type': recipe_doc['type'],
            'source_colors': recipe_doc['source_colors'],
            'mixing_ratios': recipe_doc['mixing_ratios'],
            'target_rgb': recipe_doc['target_rgb'],
            'target_cmyk': recipe_doc['target_cmyk'],
            'result_rgb': recipe_doc['result_rgb'],
            'accuracy': recipe_doc['accuracy'],
            'instructions': recipe_doc['instructions'],
            'addedAt': 'Server Timestamp',
            'source': recipe_doc['source'],
            'tags': recipe_doc['tags']
        }
        
        return {
            "success": True,
            "message": f"Recipe '{recipe_data['name']}' saved successfully",
            "recipe_id": recipe_id,
            "recipe_data": recipe_data_serializable
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to save recipe: {str(e)}"
        }

def create_user_profile(user_id: str, profile_data: dict = None):
    """Create or update user profile - stores only UID"""
    try:
        if not user_id:
            return {"success": False, "error": "User ID is required"}
        
        # Initialize Firestore client
        db = initialize_firebase()
        if not db:
            return {"success": False, "error": "Failed to initialize Firebase"}
        
        # Simple user document with just UID and timestamps
        user_doc = {
            'uid': user_id,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'lastActive': firestore.SERVER_TIMESTAMP
        }
        
        # Save to Firestore (merge to avoid overwriting existing data)
        doc_ref = db.collection('users').document(user_id)
        doc_ref.set(user_doc, merge=True)
        
        # Convert Firestore timestamps to strings for JSON serialization
        user_data_serializable = {
            'uid': user_doc['uid'],
            'createdAt': 'Server Timestamp',
            'lastActive': 'Server Timestamp'
        }
        
        return {
            "success": True,
            "message": "User profile created/updated successfully",
            "user_id": user_id,
            "user_data": user_data_serializable
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to create user profile: {str(e)}"
        }

# Create the Database agent
database_agent = Agent(
    name="database_agent",
    description="Specialized agent for Firebase Firestore operations. Handles saving and retrieving color data, mixing results, and user profiles.",
    model="gemini-2.0-flash-exp",
    tools=[
        save_color_to_inventory,
        get_user_inventory,
        save_mixing_result,
        get_mixing_history,
        create_user_profile,
        save_mixed_color_to_inventory,
        save_recipe_to_inventory
    ],
    instruction=(
        "Use the provided tools to interact with Firebase Firestore database. "
        "Save color data to user inventories, store mixing results in user history, "
        "and manage user profiles. Always validate user IDs and handle errors gracefully. "
        "Ensure data integrity and follow the established Firestore data structure."
    )
)

if __name__ == "__main__":
    # Test database operations
    test_user_id = "test_user_123"
    
    # Test color saving
    test_color = {
        "name": "Ocean Blue",
        "rgb": {"r": 0, "g": 119, "b": 190},
        "hex": "#0077BE",
        "source": "manual_entry",
        "tags": ["blue", "ocean", "primary"]
    }
    
    print("Testing color save...")
    result = save_color_to_inventory(test_user_id, test_color)
    print(json.dumps(result, indent=2))
    
    # Test inventory retrieval
    print("\nTesting inventory retrieval...")
    inventory = get_user_inventory(test_user_id)
    print(json.dumps(inventory, indent=2))
