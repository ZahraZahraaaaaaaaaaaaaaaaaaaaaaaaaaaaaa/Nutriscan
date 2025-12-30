# 🍎 Smart Food Scanner (NutriScan)

<div align="center">
  
  **Scan. Analyze. Choose Wisely.**
  
  A Flutter mobile app that empowers users to make informed food choices through instant barcode scanning and personalized health analysis.
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.38.5-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue.svg)](https://github.com/yourusername/smart_food_scanner)
</div>

---

## ✨ Features

### 📸 Core Functionality
- **📷 Barcode Scanning**: Real-time camera-based barcode scanning using mobile_scanner
- **⌨️ Manual Entry**: Alternative input method for barcode numbers
- **🔍 Product Analysis**: Fetches comprehensive data from Open Food Facts API
- **💚 Health Verdicts**: AI-powered health recommendations (Good/Warning/Not Recommended)
- **📊 Nutrition Facts**: Detailed breakdown of calories, protein, carbs, sugars, fats, fiber, salt
- **⭐ History & Favorites**: Save and manage up to 20 recent scans and unlimited favorites
- **📴 Offline Support**: Last viewed product cached for 24 hours

### 👤 Personalized Health Profiles
- **🏃 General Health**: Standard nutrition guidelines
- **🩺 Diabetes Care**: Low sugar recommendations (<10g per 100g)
- **❤️ Heart Health**: Low sodium and saturated fat monitoring
- **💪 Fitness & Sports**: Higher calorie allowances for active lifestyles
- **🍼 PCOS Management**: Specialized recommendations
- **⚖️ Weight Goals**: Customized for weight loss, gain, or maintenance

### 🎨 Design Features
- Modern, clean UI with gradient backgrounds
- NutriScan brand colors (burgundy, rose, pink palette)
- Smooth animations and transitions
- Responsive design for all screen sizes
- Material Design 3 components
- Dark mode ready

---

## 📱 Screenshots

| Home Screen | Scanner | Product Details | Health Profile |
|------------|---------|-----------------|----------------|
| 🏠 | 📷 | 📊 | 👤 |

*Note: Add screenshots to `screenshots/` folder for better visibility*

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.0.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Android device** or emulator (API level 21+)
- **iOS device** or simulator (iOS 12.0+) - Optional

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart_food_scanner.git
   cd smart_food_scanner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For specific device
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

### Building Release APK

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── product.dart                   # Product & NutritionFacts
│   └── user_profile.dart              # User profile with health data
├── providers/                         # State management (Provider pattern)
│   ├── auth_provider.dart             # Authentication & guest mode
│   ├── product_provider.dart          # Product scanning & fetching
│   ├── user_profile_provider.dart     # User profile management
│   └── history_provider.dart          # Scan history & favorites
├── screens/                           # UI screens
│   ├── splash_screen.dart             # Animated splash screen
│   ├── welcome_screen.dart            # Onboarding flow
│   ├── home_screen.dart               # Main dashboard
│   ├── scanner_screen.dart            # Camera barcode scanner
│   ├── manual_entry_screen.dart       # Manual barcode input
│   ├── product_details_screen.dart    # Detailed product view
│   ├── history_screen.dart            # Recent scans & favorites
│   ├── profile_screen.dart            # Health profile editor
│   └── settings_screen.dart           # App settings
├── services/                          # Business logic
│   ├── api_service.dart               # Open Food Facts API client
│   ├── health_analyzer.dart           # Health verdict engine
│   ├── calorie_calculator.dart        # BMR/TDEE calculations
│   ├── offline_cache_service.dart     # Local caching
│   └── cloud_repository.dart          # Firebase integration (optional)
├── widgets/                           # Reusable widgets
│   ├── product_result_dialog.dart     # Scan result popup
│   └── offline_indicator.dart         # Offline mode indicator
└── theme/
    └── app_theme.dart                 # App-wide theming
```

---

## 🔧 Configuration

### API Integration
The app uses the **Open Food Facts API** (no API key required):
- **Base URL**: `https://world.openfoodfacts.org/api/v0`
- **Endpoint**: `/product/{barcode}.json`
- **User Agent**: `SmartFoodScanner/1.0`
- **Documentation**: [Open Food Facts API](https://wiki.openfoodfacts.org/API)

### Firebase (Optional)
Firebase is optional. The app works fully in guest mode without it.

To enable Firebase features (Google Sign-In, cloud sync):
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` (Android) and place in `android/app/`
3. Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
4. Enable Authentication and Firestore in Firebase Console

---

## 📦 Dependencies

### Core
- **flutter**: ^3.0.0
- **provider**: ^6.1.1 - State management
- **http**: ^1.1.0 - API calls
- **dio**: ^5.3.2 - Advanced HTTP client
- **intl**: ^0.18.1 - Internationalization

### Camera & Scanning
- **camera**: ^0.10.5+5 - Camera access
- **mobile_scanner**: ^3.5.6 - Fast barcode scanning

### Storage
- **shared_preferences**: ^2.2.2 - Key-value storage
- **sqflite**: ^2.3.0 - SQLite database
- **cached_network_image**: ^3.3.0 - Image caching

### Firebase (Optional)
- **firebase_core**: ^4.3.0
- **firebase_auth**: ^6.1.3
- **cloud_firestore**: ^6.1.1
- **google_sign_in**: ^6.2.1

---

## 🧮 Health Analysis Algorithm

### Calorie Calculation
- **BMR (Basal Metabolic Rate)**: Mifflin-St Jeor Equation
  ```
  BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + s
  s = +5 for males, -161 for females
  ```
- **TDEE**: BMR × Activity Factor (1.2 for sedentary)
- **Goal Adjustment**: ±500 kcal for weight change

### Health Verdict Criteria
| Metric | Good | Warning | Bad |
|--------|------|---------|-----|
| Sugar | <10g | 10-25g | >25g |
| Fat | <10g | 10-20g | >20g |
| Saturated Fat | <2g | 2-5g | >5g |
| Salt | <0.3g | 0.3-1.5g | >1.5g |

*Per 100g of product*

---

## 🐛 Troubleshooting

### Common Issues

**NDK Corruption Error**
```bash
# Delete corrupted NDK and let Flutter re-download
rm -rf C:\Users\<YourUser>\AppData\Local\Android\Sdk\ndk\28.2.13676358
flutter clean
flutter run
```

**Firebase Not Configured (Warning)**
- This is normal if you haven't set up Firebase
- App will run in guest mode without cloud sync
- See Firebase section above to enable cloud features

**Build Gradle Errors**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Camera Permission Issues**
- Ensure camera permissions are granted in device settings
- Check `AndroidManifest.xml` has `<uses-permission android:name="android.permission.CAMERA" />`

---

## 🎯 Roadmap

- [ ] **Barcode History Search**: Filter and search through scan history
- [ ] **Product Comparison**: Side-by-side comparison of products
- [ ] **Meal Tracking**: Daily nutrition tracking
- [ ] **Custom Alerts**: Allergen and ingredient warnings
- [ ] **Multi-language Support**: i18n implementation
- [ ] **Dark Mode**: Complete dark theme
- [ ] **Widget Support**: Home screen widgets for quick scanning
- [ ] **Share Feature**: Share product reports
- [ ] **Offline Database**: Extended offline product database

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Open Food Facts** - For providing the comprehensive food database API
- **Flutter Team** - For the amazing framework
- **Material Design** - For design inspiration

---

## 📧 Contact

**Project Link**: [https://github.com/yourusername/smart_food_scanner](https://github.com/yourusername/smart_food_scanner)

**Developer**: Your Name
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)

---

<div align="center">
  Made with ❤️ using Flutter
  
  **⭐ Star this repo if you find it helpful!**
</div>
