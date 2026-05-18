# Activ Education Platform

This repository contains two main applications for the Activ Education platform:

1. **Flutter App** (`activ_education/`) - Mobile/web client for students, parents, and counselors
2. **React Admin App** (`activ_education_admin/`) - Admin dashboard for content management

## 📁 Repository Structure

```
activ-education/
├── activ_education/                 # Flutter mobile/web application
├── activ_education_admin/           # React administration dashboard
└── README.md                        # This file
```

## 🚀 Getting Started

### Prerequisites

- **Flutter App**: Flutter SDK (>= 3.0.0), Dart, and an emulator or physical device
- **React Admin App**: Node.js (>= 16.x) and npm or yarn
- **Backend**: Spring Boot API running on `http://localhost:8080/api/v1` (adjustable via environment variables)

### Flutter App (`activ_education/`)

#### Installation

```bash
cd activ_education
flutter pub get
```

#### Running the App

- **On detected device (mobile/emulator)**:
  ```bash
  flutter run
  ```

- **On Chrome (web)**:
  ```bash
  flutter run -d chrome
  ```

- **On Linux desktop**:
  ```bash
  flutter run -d linux
  ```

#### Production Builds

```bash
flutter build apk          # Android APK
flutter build ios          # iOS archive (requires macOS)
flutter build web          # Web production build
flutter build linux        # Linux desktop app
```

#### Environment Configuration

Create a `.env` file in the `activ_education/` root:

```
API_BASE_URL=http://localhost:8080/api/v1
API_SKIP_NGROK_WARNING=true   # Set to true to skip ngrok warnings (optional)
```

### React Admin App (`activ_education_admin/`)

#### Installation

```bash
cd activ_education_admin
npm install
```

#### Development Server

```bash
npm run dev
```

#### Preview Production Build

```bash
npm run preview
```

#### Linting

```bash
npm run lint
```

#### Environment Configuration

Create a `.env` file in the `activ_education_admin/` root (or configure API URLs in individual service files):

```
VITE_API_BASE_URL=http://localhost:8080/api/v1
```

## 🏗️ Architecture Overview

### Flutter App Architecture

The Flutter app follows a layered architecture:

- **Presentation Layer** (`lib/screens/`) - UI screens organized by feature (auth, home, explorer, etc.)
- **Widgets Layer** (`lib/widgets/`) - Reusable components (buttons, text fields, layouts)
- **Services Layer** (`lib/services/`) - API communication and business logic
  - `ApiService.dart` - Singleton Dio client with interceptors
  - Feature-specific services (AuthService, AcademicService, etc.)
- **Models Layer** (`lib/models/`) - Data models for API requests/responses
- **Theme Layer** (`lib/theme/`) - Colors, typography, and route constants

Key characteristics:
- Uses Dio for HTTP calls with `flutter_secure_storage` for JWT token management
- Follows Material Design with custom Nunito typography
- Implements 5-tab bottom navigation for main app sections
- Currently uses basic `setState` for state management (planned migration to Provider/Riverpod)

### React Admin App Architecture

The React admin uses a modern React stack:

- **Routing**: `react-router-dom` with protected routes via `PrivateRoute`
- **State Management**: `@tanstack/react-query` for data fetching and caching
- **HTTP Client**: `axios` for API communication
- **Forms**: `react-hook-form` for form handling and validation
- **Styling**: Tailwind CSS for utility-first styling
- **Charts**: `recharts` for data visualization
- **Icons**: `lucide-react` for consistent icon set

Structure:
- `src/pages/` - Individual page components (Dashboard, Eleves, Quiz, etc.)
- `src/components/` - Shared components (Layout, etc.)
- `src/App.jsx` - Router configuration and app entry point

### API Integration

Both applications communicate with a Spring Boot backend:

- **Base URL**: `http://localhost:8080/api/v1` (configurable via environment)
- **Authentication**: Currently uses `trackingId` (UUID) in URLs, planned migration to JWT
- **Pagination**: Standard `Page<T>` format with `content`, `totalElements`, `totalPages`
- **Date Format**: ISO 8601 (`YYYY-MM-DDTHH:mm:ss`)
- **Modules**: 15+ API modules covering users, academics, library, quiz, messages, appointments, etc.

## 🔑 Important Notes

1. **Flutter App Details**: For comprehensive Flutter-specific guidance including:
   - Detailed directory structure
   - Design system (colors, typography, components)
   - Navigation flow
   - Service architecture
   - Testing guidelines
   - Refer to `activ_education/CLAUDE.md` (if available)

2. **State Management**: 
   - Flutter app currently uses basic `setState` (migration to Provider/Riverpod recommended)
   - React admin uses `@tanstack/react-query` for server state and local component state for UI

3. **Authentication Status**: 
   - Both apps currently use temporary `trackingId` authentication
   - JWT implementation is in progress for production readiness

4. **Development Workflow**:
   - Start backend server first (Spring Boot on port 8080)
   - Run Flutter app for client development
   - Run React admin for admin dashboard development
   - Use `flutter run -d chrome` for web testing of Flutter app

5. **File Conventions**:
   - Flutter: `snake_case.dart` for files, `lowerCamelCase` for variables/functions
   - React: `.jsx` extension, PascalCase for components, camelCase for props/variables

## 📦 Dependencies

### Flutter App
Key dependencies (see `pubspec.yaml` for full list):
- `dio`: ^5.0.0
- `flutter_secure_storage`: ^8.0.0
- `flutter_svg`: ^2.0.0
- `google_fonts`: ^6.0.0
- `intl`: ^0.18.0
- `path_provider`: ^2.0.0
- `shared_preferences`: ^2.0.0

### React Admin App
Key dependencies (see `package.json` for full list):
- `react`: ^18.0.0
- `react-dom`: ^18.0.0
- `react-router-dom`: ^6.0.0
- `@tanstack/react-query`: ^5.0.0
- `axios`: ^1.0.0
- `react-hook-form`: ^7.0.0
- `tailwindcss`: ^3.0.0
- `recharts`: ^2.0.0
- `lucide-react`: ^0.200.0

## 🧪 Testing

### Flutter App
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (requires device/emulator)
flutter drive --target=test_driver/app.dart
```

### React Admin App
```bash
# Run tests (if configured)
npm test
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the existing style and conventions.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For questions or support, please open an issue in this repository.

---

*Generated with ❤️ for the Activ Education platform*