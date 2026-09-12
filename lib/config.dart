class Config {
  // Replace with your backend base URL
  static const backendBaseUrl = 'https://YOUR_BACKEND_URL';

  // Optional: placeholder auth token for testing; replace with real token retrieval
  static const placeholderAuthToken = 'YOUR_AUTH_TOKEN';

  // Firebase options placeholder map. Replace with your Firebase project values.
  static const firebaseOptions = {
    'apiKey': 'YOUR_API_KEY',
    'authDomain': 'YOUR_AUTH_DOMAIN',
    'projectId': 'YOUR_PROJECT_ID',
    'storageBucket': 'YOUR_STORAGE_BUCKET',
    'messagingSenderId': 'YOUR_MESSAGING_SENDER_ID',
    'appId': 'YOUR_APP_ID',
  };

  // WebSocket URL (wss). Replace with your WS endpoint.
  static const websocketUrl = 'wss://YOUR_WEBSOCKET_URL';
}
// Placeholder configuration - replace with real values before deploying

const String backendBaseUrl = 'https://YOUR_BACKEND_URL';
const String wsBaseUrl = 'wss://YOUR_BACKEND_WS_URL';
const String authTokenPlaceholder = 'YOUR_AUTH_TOKEN';

const Map<String, dynamic> firebaseConfigPlaceholder = {
  'apiKey': 'YOUR_FIREBASE_API_KEY',
  'appId': 'YOUR_FIREBASE_APP_ID',
  'messagingSenderId': 'YOUR_MESSAGING_SENDER_ID',
  'projectId': 'YOUR_PROJECT_ID',
};
