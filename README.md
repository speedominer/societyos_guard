# SocietyOS Guard (Flutter)

Starter scaffold for the Guard mobile/tablet app.

Run:

```bash
cd "c:\Users\Mehul Pawar\Documents\Security"
flutter pub get
flutter run
```

Notes:
- Set your backend URL and placeholder token in `lib/config.dart` (update `backendBaseUrl` and `placeholderAuthToken`).
- Firebase config placeholders are in `lib/config.dart` and `lib/firebase_config.dart`.
- ApiService instances in the code read `Config.backendBaseUrl`.
- Firebase messaging requires configuring Android/iOS firebase projects.
- This scaffold provides core screens, widgets and services. Continue implementing WebSocket subscription and full flows.
