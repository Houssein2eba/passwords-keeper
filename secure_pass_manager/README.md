# Password Guardian

A Flutter application for securely managing password entries locally with GetX state management, encrypted storage, and biometric authentication.

## Features

✅ **Secure Local Storage**: Encrypted Hive database with 256-bit AES encryption  
✅ **App Lock**: PIN (4-8 digits) + Biometric authentication (Face ID/Touch ID)  
✅ **Full CRUD Operations**: Create, Read, Update, Delete password entries  
✅ **Smart Search**: Debounced search by site name or username  
✅ **Password Generator**: Generate strong random passwords  
✅ **Clipboard Security**: Auto-clear clipboard after 30 seconds  
✅ **Auto-lock**: Locks after 1 minute of inactivity or on app background  
✅ **Screenshot Prevention**: FLAG_SECURE on Android  
✅ **Modern UI**: Dark theme with smooth animations  

## Tech Stack

- **Framework**: Flutter 3.7+
- **State Management**: GetX 4.6.6
- **Local Storage**: Hive 2.2.3 (encrypted)
- **Security**: flutter_secure_storage, local_auth, crypto
- **UI**: Material Design with custom dark theme

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app_lock/
│   ├── app_lock_controller.dart       # PIN + biometric logic
│   └── lock_screen.dart               # Lock screen UI
├── data/
│   ├── password_entry.dart            # Hive model
│   ├── hive_manager.dart              # Encrypted storage setup
│   └── password_repository.dart       # CRUD operations
├── ui/
│   ├── home_screen.dart               # Main list screen
│   ├── edit_entry_screen.dart         # Create/edit form
│   ├── entry_detail_sheet.dart        # Detail bottom sheet
│   └── widgets/
│       ├── password_card.dart         # List item widget
│       ├── empty_state.dart           # Empty state UI
│       └── secure_text.dart           # Password masking widget
└── utils/
    ├── clipboard_helper.dart          # Clipboard with auto-clear
    ├── validators.dart                # Form validators
    └── formatters.dart                # Date/text formatters
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Android Studio / VS Code with Flutter extensions
- Android device/emulator (API 21+) or iOS device/simulator

### Installation

1. **Clone or navigate to the project directory**:
   ```bash
   cd secure_pass_manager
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android

- Minimum SDK: 21
- Permissions automatically configured in `AndroidManifest.xml`
- Screenshot prevention enabled via `FLAG_SECURE`

#### iOS

- Minimum iOS: 12.0
- Face ID/Touch ID permission configured in `Info.plist`
- Add signing certificate in Xcode before running on physical device

## Usage

### First Launch

1. App opens to lock screen
2. Set a 4-8 digit PIN
3. Confirm PIN
4. (Optional) Enable biometric authentication in settings

### Adding a Password

1. Tap the **+** button (FAB)
2. Fill in:
   - Site name (required)
   - Username/Email (required)
   - Password (required) - or tap refresh icon to generate
   - Notes (optional)
3. Tap **Save**

### Viewing/Editing Passwords

1. Tap any password card to view details
2. Use **Copy** buttons to copy username/password
3. Tap **Edit** to modify entry
4. Tap **Delete** to remove (with confirmation)

### Search

- Use the search bar at the top
- Searches site name and username
- Results update as you type (300ms debounce)

### Security Features

- **Auto-lock**: App locks after 1 minute of inactivity
- **Background lock**: App locks when going to background
- **Clipboard auto-clear**: Copied passwords clear after 30 seconds
- **Password masking**: Passwords hidden by default, reveal with toggle
- **Screenshot prevention**: Android prevents screenshots/screen recording

## Security Architecture

### Encryption

- **Storage**: Hive box encrypted with AES-256
- **Key Management**: 256-bit key stored in OS keychain via `flutter_secure_storage`
- **PIN Storage**: PBKDF2-hashed with 10,000 iterations + salt

### Data Flow

1. App starts → Load encryption key from secure storage
2. Open encrypted Hive box
3. User unlocks with PIN/biometric
4. CRUD operations write to encrypted box
5. App locks on inactivity/background

### Threat Model

✅ **Protected Against**:
- Physical device access (app lock)
- Data extraction from storage (encryption)
- Screenshots/screen recording (FLAG_SECURE)
- Clipboard snooping (auto-clear)

⚠️ **Not Protected Against**:
- Device compromise with root/jailbreak
- Keyloggers on compromised device
- Shoulder surfing during password entry

## Development

### Running Tests

```bash
flutter test
```

### Code Generation

After modifying Hive models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

## Troubleshooting

### "Developer Mode not enabled" (Windows)

This warning is safe to ignore during development. To fix:
1. Open Windows Settings
2. Go to "For developers"
3. Enable "Developer Mode"

### Biometric not working

- Ensure device has biometric hardware
- Check biometric is enrolled in device settings
- Verify permissions in app settings

### Data loss after reinstall

This is expected behavior. Encryption key is stored in OS keychain and cleared on uninstall. There is no recovery mechanism by design.

## License

This project is for educational/personal use.

## Contributing

Feel free to submit issues or pull requests for improvements.
