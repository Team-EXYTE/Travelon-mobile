# Travelon

Travelon is a modern Flutter app for discovering, sharing, and booking travel experiences and events. It features seamless authentication, a beautiful moments feed, event booking, and robust integration with Firebase services.

![Travelon Logo](assets/logo.png)

---

## Features

- **Modern UI**: Glassmorphic app bar, soft gradients, and beautiful card layouts.
- **Authentication**: Secure sign up and login with Firebase Auth.
- **Moments Feed**: Share and explore travel moments with images, location, and user overlays.
- **Event Booking**: Book events, manage tickets, and track your bookings.
- **Profile Management**: Upload profile images and manage your traveller profile.
- **Phone Number & OTP**: Sri Lanka (+94) phone formatting, SMS subscription, and OTP verification.
- **Firestore Integration**: Robust Firestore rules, ticketing, and user booking tracking.

---

|Login    |        Signup    |                        
| :-----------: | :-------------------: | 
| <img src="assets/login.jpg" alt="Login" width="250"/> | <img src="assets/signup.jpg" alt="Signup" width="250"/> |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio or Xcode for emulators/simulators

### Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/Team-EXYTE/Travelon-mobile.git
   cd travelon_mobile
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Firebase setup:**
   - Add your `google-services.json` (Android) to `android/app/`.
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`.
   - Ensure Firestore and Authentication are enabled in your Firebase project.
4. **Run the app:**
   ```sh
   flutter run
   ```

---

## Key Technologies

- **Flutter** (Dart)
- **Firebase Auth**
- **Cloud Firestore**
- **Firebase Storage**
- **MSpace API** (for SMS/OTP)

---

## License

[MIT](LICENSE)

---

## Credits

- Built by Team-EXYTE.
