# Firebase Firestore Setup Guide

## Quick Setup (3 hours before deadline)

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `'shadesmith-b8de1`
3. Click "Firestore Database" in left sidebar
4. Click "Create database"
5. Choose "Start in test mode" (for development)
6. Select location: `nam5` (same as your current setup)

### 2. Update Security Rules
Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow users to read/write their own inventory
      match /inventory/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Allow users to read/write their own mixing history
      match /mixing_history/{mixingId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 3. Database Structure
Your Firestore will have this structure:

```
users/
  {user_id}/
    uid: "user_123"
    createdAt: timestamp
    lastActive: timestamp
    
    inventory/
      {color_id}/
        id: "color_uuid"
        name: "Ocean Blue"
        rgb: {r: 0, g: 119, b: 190}
        hex: "#0077BE"
        cmyk: {c: 100, m: 37, y: 0, k: 25}
        tags: ["blue", "ocean"]
    
    mixing_history/
      {mixing_id}/
        id: "mixing_uuid"
        user_colors: [{r: 0, g: 119, b: 190}, {r: 255, g: 140, b: 0}]
        target_rgb: {r: 128, g: 130, b: 95}
        result_rgb: {r: 125, g: 128, b: 92}
        mixing_ratios: [0.6, 0.4]
        accuracy: {distance: 5.2, level: "Excellent"}
        createdAt: timestamp
        success: true
```

### 4. Test the Setup
Once Firestore is set up, test with:

```bash
# Create user profile
curl -X POST http://localhost:8080/create-user-profile \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test_user_123"}'

# Save a color
curl -X POST http://localhost:8080/save-color \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user_123",
    "color_data": {
      "name": "Ocean Blue",
      "rgb": {"r": 0, "g": 119, "b": 190},
      "hex": "#0077BE",
      "source": "manual"
    }
  }'

# Get inventory
curl -X GET http://localhost:8080/get-inventory/test_user_123
```

### 5. Available CRUD Endpoints

**User Management:**
- `POST /create-user-profile` - Create user (stores only UID)
- `GET /get-inventory/<user_id>` - Get user's colors
- `GET /get-mixing-history/<user_id>` - Get user's mixing history

**Color Management:**
- `POST /save-color` - Save color to inventory
- `GET /get-color/<user_id>/<color_id>` - Get specific color
- `PUT /update-color/<user_id>/<color_id>` - Update color
- `DELETE /delete-color/<user_id>/<color_id>` - Delete color

**Mixing Results:**
- `POST /save-mixing-result` - Save mixing result
- `GET /get-mixing-result/<user_id>/<mixing_id>` - Get specific result
- `DELETE /delete-mixing-result/<user_id>/<mixing_id>` - Delete result

### 6. For Production
- Update security rules to be more restrictive
- Add authentication middleware
- Add data validation
- Add error handling for network issues
- Add backup strategies

## Current Status
✅ Database agent created
✅ CRUD endpoints implemented
✅ Flask integration complete
⏳ Firestore database setup needed
⏳ Testing with real database
