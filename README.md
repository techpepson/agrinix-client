# Agrinix App

Agrinix is a mobile application designed to aid farmers in early detection of crop diseases using AI. The app allows farmers to take a picture of their crops, and a trained AI model predicts the disease type, symptoms, prevention methods, and more. Agrinix also features a community forum, crop library, and weather services to empower farmers with knowledge and support.

---

## 🚀 Features

- **AI Crop Disease Detection:** Instantly diagnose crop diseases by capturing or uploading images.
- **Community Forum:** Share experiences, ask questions, and get advice from other farmers.
- **Crop Library:** Access a comprehensive database of crops, diseases, and pests.
- **Weather Services:** Get real-time weather updates relevant to farming activities.
- **Authentication:** Secure login and registration for users.
- **Responsive UI:** Modern, user-friendly interface for mobile and web.

---

## 🛠️ Tech Stack

- **Flutter** (Dart) — Cross-platform mobile/web app
- **Riverpod** — State management
- **Dio** — Networking
- **GoRouter** — Navigation
- **Share Plus** — Sharing content
- **Cached Network Image** — Efficient image loading
- **Flutter Native Splash** — Custom splash screens
- **Other:** Geolocator, Image Picker, Flutter Secure Storage, etc.

---

## 📁 Folder Structure

```
lib/
  config/         # Fonts, theme, and app-wide config
  core/           # Core logic and services
  data/           # Static and mock data
  models/         # Data models
  providers/      # Riverpod providers
  routes/         # App routing
  screens/        # UI screens (auth, community, library, etc.)
  services/       # API and business logic
  widgets/        # Reusable widgets
assets/
  images/         # App images and logos
  fonts/          # Custom fonts
  animations/     # Animations
```

---

## 📝 Getting Started

### 1. **Clone the Repository**

```sh
git clone https://github.com/your-username/agrinix_app.git
cd agrinix_app
```

### 2. **Install Dependencies**

```sh
flutter pub get
```

### 3. **Set Up Environment Variables**

- Copy the `.env.example` (if available) to `.env` and fill in your API keys and server URLs.
- Example:
  ```env
  SERVER_BASE_URL=https://your-api-url.com
  ```

### 4. **Run the App**

- For mobile (Android/iOS):
  ```sh
  flutter run
  ```
- For web:
  ```sh
  flutter run -d chrome
  ```

### 5. **Generate Splash Screen (Optional)**

If you change the splash screen config in `pubspec.yaml`, regenerate it:

```sh
flutter pub run flutter_native_splash:create
```

---

## ⚙️ Customizing the Splash Screen

- Edit the `flutter_native_splash` section in `pubspec.yaml` to change the splash image, background color, or branding.
- After editing, run:
  ```sh
  flutter pub run flutter_native_splash:create
  ```

---

## 🧪 Running Tests

```sh
flutter test
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact & Support

- **Project Lead:** [Your Name](mailto:your.email@example.com)
- **Issues:** Please use the [GitHub Issues](https://github.com/your-username/agrinix_app/issues) page for bug reports and feature requests.

---

**Empowering farmers with AI and community.**
