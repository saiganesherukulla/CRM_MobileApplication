# CTRL F Flutter Mobile App

Flutter mobile frontend for the CTRL F platform. This app uses the same Spring Boot backend as the React web app.

## Run

Start the backend first:

```powershell
cd ..\springboot-backend
mvn spring-boot:run
```

Install Flutter packages:

```powershell
flutter pub get
```

Android emulator:

```powershell
flutter run --dart-define=CRM_API_BASE_URL=http://10.0.2.2:8080/api
```

Physical Android device on the same Wi-Fi:

```powershell
flutter run --dart-define=CRM_API_BASE_URL=http://<your-computer-lan-ip>:8080/api
```

Production API:

```powershell
flutter run --dart-define=CRM_API_BASE_URL=https://api.your-domain.com/api
```

## Build

Debug APK:

```powershell
flutter build apk --debug --dart-define=CRM_API_BASE_URL=http://<your-computer-lan-ip>:8080/api
```

Release APK:

```powershell
flutter build apk --release --dart-define=CRM_API_BASE_URL=https://api.your-domain.com/api
```

Debug APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Release APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Mobile App Structure

```text
lib
  models/      API response models for clients, tasks, projects, tickets, flow, etc.
  router/      Navigation and route protection
  screens/     Auth, dashboard, clients, tasks, projects, tickets, emails, flow, reports, settings
  services/    Backend API client, auth session, settings summaries
  theme/       App colors, typography, and Material theme
  widgets/     Shared app shell, cards, avatars, loading/error states
```

## Connected Backend Areas

```text
Auth and first admin bootstrap
Dashboard summary
Clients and primary contacts
Team members, roles, departments
Tasks and comments
Projects and development delivery phases
Support tickets
Email accounts, providers, sync, and outbound email records
CTRL F flow items and document links
Reports and analytics
Settings, preferences, system status, and audit logs
```

## Useful Commands

```powershell
flutter pub get
flutter analyze --no-pub
flutter test
flutter build apk --debug --no-pub
flutter build apk --release --dart-define=CRM_API_BASE_URL=https://api.your-domain.com/api
```

## Backend URL Notes

Use these common API URLs:

```text
Android emulator to local backend: http://10.0.2.2:8080/api
Physical phone to local backend:  http://<your-computer-lan-ip>:8080/api
Production backend:              https://api.your-domain.com/api
```

The phone and backend computer must be on the same Wi-Fi for LAN testing. The backend CORS configuration must also allow the LAN origin.

## Production Checklist

- Set the production API URL with `--dart-define=CRM_API_BASE_URL=...`.
- Configure Android release signing before distributing outside debug testing.
- Use HTTPS for the backend.
- Verify login, team member creation, client/contact creation, tasks, tickets, projects, CTRL F flow, and settings against the production backend.
- Configure real email provider credentials in the backend or through the admin settings UI.
- Use a persistent backend file storage location for workflow documents.
