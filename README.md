# 🎨 ShadeSmith - AI Color Mixing Recipes

**Snap a color → Get AI-generated mixing recipe → Preview in AR → Save/share**

A Flutter app that uses AI to generate accurate color mixing recipes using materials you actually have, with AR preview capabilities.

## 🚀 Hackathon Demo Features

### ✅ Implemented (36-hour MVP)
- **Camera Color Scanner** - Tap to sample colors from camera
- **Color Analysis** - HEX, RGB, HSL color space conversions
- **Inventory Management** - Toggle base colors you own
- **AI Recipe Generation** - Mock AI that generates realistic mixing ratios
- **Recipe Display** - Beautiful cards showing ingredients and percentages
- **Save & Share** - Save recipes locally, share functionality ready
- **Settings** - Accessibility options and app configuration
- **iOS Native** - Optimized for iOS with Material 3 design

### 🔮 Future Features (Stretch Goals)
- **Real AI Integration** - Cloud Run API for actual recipe generation
- **AR Preview** - ARKit overlay showing predicted color
- **Smart Inventory Scan** - OCR + computer vision for automatic color detection
- **Firebase Backend** - Cloud storage and real-time sync
- **Advanced Color Spaces** - LAB, CMYK, perceptual color matching
- **Batch Processing** - Import brand style guides

## 🎯 Target Users
- **DIY Painters** - Wall touch-ups and palette creation
- **Makeup Artists** - Shade matching and blending
- **Makers/Artists** - Inks, dyes, acrylics
- **Accessibility** - Color-blind users with descriptive tags

## 🏗️ Technical Architecture

### Frontend (Flutter)
- **State Management**: Provider pattern
- **Navigation**: GoRouter for type-safe routing
- **Camera**: Native camera integration with image processing
- **Storage**: SharedPreferences for local data
- **UI**: Material 3 design system

### Backend (Planned)
- **API**: Cloud Run FastAPI service
- **Database**: Firestore for user data and recipes
- **Storage**: Firebase Storage for images
- **AI**: Vertex AI for recipe generation and QA
- **Auth**: Firebase Anonymous + Google Sign-In

## 📱 App Screens

1. **Home** - Welcome screen with quick actions
2. **Camera** - Color scanning with tap-to-sample
3. **Inventory** - Manage your base color collection
4. **Recipe** - View generated mixing instructions
5. **Saved** - Browse your saved recipes
6. **Settings** - App configuration and accessibility

## 🚀 Quick Start (Hackathon Demo)

### Prerequisites
- Flutter 3.8.1+
- iOS Simulator or physical iOS device
- Xcode (for iOS development)

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd shadesmith

# Install dependencies
flutter pub get

# Run on iOS
flutter run -d "iPhone 16 Pro Max"
```

### Demo Flow
1. **Launch app** - See welcome screen
2. **Tap "Scan Color"** - Use camera to sample a color
3. **Tap on image** - Select color from camera feed
4. **Review color** - See HEX, RGB, HSL values
5. **Tap "Use This Color"** - Return to home
6. **Tap "Generate Recipe"** - Get AI mixing recipe
7. **View Recipe** - See ingredients and percentages
8. **Save Recipe** - Add to your collection
9. **Check Inventory** - Manage your base colors
10. **Browse Saved** - View your recipe library

## 🎨 Demo Scenarios

### Scenario 1: Interior Designer
- Scan a paint chip from a client's room
- Generate recipe using available base colors
- Save recipe for later reference
- Share with team members

### Scenario 2: Makeup Artist
- Capture a desired lipstick shade
- Check available makeup base colors
- Get precise mixing ratios
- Create custom shade for client

### Scenario 3: Artist
- Sample color from reference image
- Generate recipe using available paints
- Save for future projects
- Export color values for other tools

## 🔧 Key Features Demonstrated

### Color Processing
- Real-time camera color sampling
- Multiple color space conversions (RGB, HSL, HEX)
- Accurate color extraction from images
- Color accuracy indicators (ΔE values)

### AI Recipe Generation
- Mock AI that generates realistic recipes
- Considers available inventory
- Provides accuracy metrics
- Shows predicted final color

### User Experience
- Intuitive tap-to-sample interface
- Beautiful Material 3 design
- Accessibility considerations
- Smooth navigation between screens

### Data Management
- Local storage for recipes and settings
- Inventory management system
- Save/delete functionality
- Share-ready data structures

## 🏆 Hackathon Judging Points

### Innovation
- **Unique Value Prop**: AI color mixing with AR preview
- **Technical Challenge**: Real-time color processing + AI integration
- **Market Need**: Serves multiple creative industries

### Technical Excellence
- **Clean Architecture**: Well-structured Flutter app
- **Performance**: Optimized camera and image processing
- **Code Quality**: Follows Flutter best practices

### User Experience
- **Intuitive Design**: Easy color scanning workflow
- **Accessibility**: Color-blind friendly features
- **Polish**: Professional UI/UX design

### Scalability
- **Modular Design**: Easy to extend with real AI
- **Cloud Ready**: Structured for Firebase integration
- **Cross-Platform**: Flutter enables iOS/Android

## 📊 Demo Metrics

- **Development Time**: 36 hours
- **Lines of Code**: ~1,500 lines
- **Features Implemented**: 8 core features
- **Screens Created**: 6 main screens
- **Dependencies**: 8 essential packages
- **Platform**: iOS (Android ready)

## 🔮 Next Steps (Post-Hackathon)

1. **Real AI Integration** - Connect to Cloud Run API
2. **Firebase Setup** - Add cloud storage and auth
3. **AR Implementation** - Add ARKit for color preview
4. **Advanced Features** - OCR, batch processing, etc.
5. **Android Support** - Complete cross-platform
6. **App Store Launch** - Polish and publish

## 📞 Contact

Built for [Your Hackathon Name] - 36 Hour Challenge

**Team**: [Your Team Name]  
**Contact**: [Your Contact Info]  
**GitHub**: [Your Repository]

---

*"From pixels to pigments - AI-powered color mixing made simple"* 🎨✨