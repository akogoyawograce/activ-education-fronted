# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📁 Repository Structure

This workspace contains two main applications:
- **Flutter App** (`activ_education/`) - Mobile/web client for students, parents, and counselors
- **React Admin App** (`activ_education_admin/`) - Admin dashboard for content management
- **Simple React App** (`educational_admin/`) - Basic React setup (minimal)

Each application has its own detailed documentation:
- Flutter app: See `activ_education/CLAUDE.md` for complete architecture, commands, and guidelines
- React admin: See `activ_education_admin/README.md` for setup instructions

## 🚀 Common Development Commands

### Flutter App (`activ_education/`)
```bash
# Install dependencies
flutter pub get

# Run on detected device (mobile/emulator)
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on Linux desktop
flutter run -d linux

# Clean build cache
flutter clean

# Run tests
flutter test

# Analyze code for linting errors
flutter analyze

# Production builds
flutter build apk          # Android APK
flutter build ios          # iOS archive (requires macOS)
flutter build web          # Web production build
flutter build linux        # Linux desktop app
```

### React Admin App (`activ_education_admin/`)
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Preview production build
npm run preview

# Run ESLint
npm run lint
```

### Environment Configuration
- Flutter app: Create `.env` file in `activ_education/` root
  - `API_BASE_URL` - Backend API URL (default: `http://localhost:8080/api/v1`)
  - `API_SKIP_NGROK_WARNING` - Set to `true` to skip ngrok warnings
- React admin: Configure API URLs in individual service files or create `.env` in its root

## 🏗️ High-Level Architecture

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
- Currently uses basic setState for state management (planned migration to Provider/Riverpod)

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
   - Refer to `activ_education/CLAUDE.md`

2. **State Management**: 
   - Flutter app currently uses basic setState (migration to Provider/Riverpod recommended)
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