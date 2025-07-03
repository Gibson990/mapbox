# Mapbox Booking App

A simple Flutter app to search for locations and track rides using Mapbox.

## Features
- Search for origin and destination locations using Mapbox Geocoding API
- View and track rides on a map
- Simple, clean UI

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable)
- A [Mapbox](https://account.mapbox.com/) account and access token

### Setup

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd mapbox_booking_app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Configure your Mapbox Access Token:**
   
   - Open `lib/config.dart`.
   - Replace the value of `mapboxAccessToken` with your own Mapbox access token:
     ```dart
     // lib/config.dart
     const String mapboxAccessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';
     ```

   **Note:** The `lib/config.dart` file is included in `.gitignore` to prevent accidental commits of your private token.

4. **Run the app:**
   ```sh
   flutter run
   ```

## Usage
- Enter the origin (From) and destination (To) location names.
- Press the search icon or hit enter to resolve each location.
- Once both locations are resolved, press "Track Ride" to view the route on the map.

## Security
- **Never share your Mapbox access token publicly.**
- The `lib/config.dart` file is ignored by git for your safety.
