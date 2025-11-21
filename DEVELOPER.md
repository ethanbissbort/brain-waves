# Brain Waves - Developer Documentation

## Overview

Brain Waves is an iOS application for generating binaural beats and isochronic tones to facilitate meditation, focus, and relaxation through brainwave entrainment.

## Architecture

### Design Patterns

- **MVVM (Model-View-ViewModel)**: Separates UI logic from business logic
- **Protocol-Oriented Programming**: Uses protocols for abstraction and testability
- **Dependency Injection**: Loose coupling via DI container
- **Singleton Pattern**: For shared managers (with DI support)
- **Observer Pattern**: Via Combine framework for reactive updates

### Project Structure

```
BrainWaves/
├── Audio/                          # Audio generation and management
│   ├── AudioGenerator.swift        # Protocol and base class
│   ├── AudioSessionManager.swift   # Audio session lifecycle
│   ├── BinauralBeatsGenerator.swift
│   └── IsochronicTonesGenerator.swift
├── Models/                         # Data models
│   ├── BinauralBeatPreset.swift
│   ├── IsochronicTonePreset.swift
│   └── Playlist.swift
├── ViewModels/                     # Business logic layer
│   ├── BaseGeneratorViewModel.swift
│   ├── BinauralBeatsViewModel.swift
│   ├── IsochronicTonesViewModel.swift
│   └── PlaylistViewModel.swift
├── Views/                          # SwiftUI views
│   ├── BinauralBeatsView.swift
│   ├── IsochronicTonesView.swift
│   ├── PresetsView.swift
│   ├── PlaylistView.swift
│   └── Components/                 # Reusable UI components
├── Persistence/                    # Data storage layer
│   ├── PresetStore.swift
│   ├── DataValidator.swift
│   └── MigrationManager.swift
├── DependencyInjection/            # DI infrastructure
│   ├── DependencyContainer.swift
│   └── Protocols.swift
├── ErrorHandling/                  # Error management
│   ├── BrainWavesError.swift
│   ├── ErrorHandler.swift
│   └── Logger.swift
├── AppConstants.swift              # App-wide constants
├── SettingsManager.swift           # User preferences
├── PresetCoordinator.swift         # Navigation coordination
└── HapticManager.swift             # Haptic feedback
```

## Phase 1 Improvements (Completed)

### 1. Dependency Injection

**Files:**
- `DependencyInjection/DependencyContainer.swift`
- `DependencyInjection/Protocols.swift`

**Usage:**
```swift
// Register dependencies (done automatically on app launch)
DependencyContainer.shared.register(MyService.self) { MyServiceImpl() }

// Inject dependencies
@Injected var presetStore: PresetStoreProtocol
@Injected var audioSession: AudioSessionManagerProtocol
```

**Benefits:**
- Improved testability (mock dependencies in tests)
- Loose coupling between components
- Easier to swap implementations

### 2. Error Handling

**Files:**
- `ErrorHandling/BrainWavesError.swift` - Error type hierarchy
- `ErrorHandling/ErrorHandler.swift` - UI error presentation
- `ErrorHandling/Logger.swift` - OSLog-based logging

**Error Types:**
- `AudioError` - Audio generation and playback errors
- `PersistenceError` - Data storage errors
- `ValidationError` - Input validation errors
- `GeneralError` - General application errors

**Usage:**
```swift
// Handle errors with user feedback
do {
    try performOperation()
} catch {
    ErrorHandler.shared.handle(error, title: "Operation Failed")
}

// Log without showing to user
ErrorHandler.shared.handleSilently(error)

// Log with categories
Logger.shared.audioInfo("Starting playback")
Logger.shared.persistenceError(error)
```

### 3. Persistence Enhancements

**Files:**
- `Persistence/DataValidator.swift` - Input validation
- `Persistence/MigrationManager.swift` - Data migration & backup

**Features:**
- Automatic data validation on save
- Schema version management
- Backup and restore functionality
- Data migration between app versions

**Usage:**
```swift
// Validation happens automatically
let preset = BinauralBeatPreset(...)
try preset.validate() // Throws if invalid

// Create backup
let backupData = try MigrationManager.shared.createBackup()

// Restore from backup
try MigrationManager.shared.restoreFromBackup(backupData)
```

### 4. Code Quality

**SwiftLint Configuration:**
- `.swiftlint.yml` - Code style rules
- Custom rules for best practices
- Integration ready for CI/CD

**Unit Tests:**
- `BrainWavesTests/Audio/` - Audio generator tests
- `BrainWavesTests/ViewModels/` - View model tests
- `BrainWavesTests/Models/` - Model tests
- `BrainWavesTests/Persistence/` - Persistence tests

**UI Tests:**
- `BrainWavesUITests/` - Critical user flow tests

**Target:** 80%+ code coverage

### 5. Documentation

**In-Code Documentation:**
- DocC-style comments on public APIs
- Code examples in documentation
- Comprehensive parameter descriptions

**Developer Guides:**
- `ROADMAP.md` - Feature roadmap and timeline
- `DEVELOPER.md` - This file

## Key Concepts

### Audio Generation

**Binaural Beats:**
- Two slightly different frequencies played in each ear
- The brain perceives a third "beat" at the difference frequency
- Example: 200 Hz (left) + 210 Hz (right) = 10 Hz beat

**Isochronic Tones:**
- Single tone that pulses on and off at a specific rate
- Amplitude modulation creates the pulse effect
- Example: 250 Hz carrier at 10 Hz pulse rate

**Brainwave Types:**
- **Delta (0-4 Hz):** Deep sleep, healing
- **Theta (4-8 Hz):** Meditation, creativity
- **Alpha (8-14 Hz):** Relaxation, light meditation
- **Beta (14-30 Hz):** Focus, alertness
- **Gamma (30+ Hz):** Peak awareness, problem solving

### Data Flow

```
User Input → ViewModel → Audio Generator → AVAudioEngine → Audio Output
                ↓
            PresetStore → UserDefaults
```

## Development Workflow

### Running Tests

```bash
# Unit tests
xcodebuild test -scheme BrainWaves -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme BrainWaves -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BrainWavesUITests
```

### Linting

```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint

# Auto-fix issues
swiftlint --fix
```

### Documentation Generation

```bash
# Generate DocC documentation
xcodebuild docbuild -scheme BrainWaves -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Best Practices

### 1. Error Handling

**DO:**
- Use typed errors from `BrainWavesError.swift`
- Provide user-friendly error messages
- Log errors for debugging
- Include recovery suggestions

**DON'T:**
- Use generic `Error` types
- Force unwrap optionals
- Swallow errors silently (unless intentional)

### 2. Logging

**DO:**
- Use `Logger.shared` instead of `print()`
- Choose appropriate log levels (debug, info, error)
- Use category-specific loggers (audio, persistence, UI)

**DON'T:**
- Log sensitive user data
- Use `print()` in production code

### 3. Dependency Injection

**DO:**
- Inject dependencies via `@Injected` property wrapper
- Program to protocols, not concrete types
- Register dependencies in `DependencyContainer`

**DON'T:**
- Use `.shared` singletons directly (use DI instead)
- Create tight coupling between components

### 4. Testing

**DO:**
- Write tests for all business logic
- Mock dependencies using protocols
- Test edge cases and error paths
- Aim for 80%+ code coverage

**DON'T:**
- Test framework code or UI layout details
- Skip error case testing
- Write brittle tests tied to implementation

### 5. Code Style

**DO:**
- Follow SwiftLint rules
- Use meaningful variable names
- Add documentation to public APIs
- Keep functions focused and small

**DON'T:**
- Ignore linter warnings
- Write functions longer than 50-100 lines
- Leave public APIs undocumented

## Common Tasks

### Adding a New Preset Type

1. Create model in `Models/`
2. Add storage keys to `AppConstants.Storage`
3. Update `PresetStore` with CRUD methods
4. Add validation to `DataValidator`
5. Create ViewModel in `ViewModels/`
6. Create View in `Views/`
7. Add to tab bar in `ContentView`

### Adding a New Audio Effect

1. Add constants to `AppConstants.AudioEffects`
2. Update `BaseAudioGenerator` or create new generator
3. Add UI controls in generator view
4. Update corresponding ViewModel
5. Write tests

### Debugging Audio Issues

1. Check `Logger.shared.audioDebug()` logs in Console.app
2. Verify `AudioSessionManager` configuration
3. Test with headphones and speakers separately
4. Check buffer generation in debugger
5. Verify frequency ranges are valid

## Resources

### Apple Documentation

- [AVFoundation](https://developer.apple.com/av-foundation/)
- [AVAudioEngine](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [Combine](https://developer.apple.com/documentation/combine)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)

### Research

- [Binaural Beats Research](https://pubmed.ncbi.nlm.nih.gov/?term=binaural+beats)
- [Brainwave Entrainment](https://scholar.google.com/scholar?q=brainwave+entrainment)

## Troubleshooting

### Build Issues

**Problem:** SwiftLint errors
**Solution:** Run `swiftlint --fix` or adjust `.swiftlint.yml`

**Problem:** Test failures
**Solution:** Clean build folder (`Cmd+Shift+K`) and rebuild

### Runtime Issues

**Problem:** Audio not playing
**Solution:** Check audio session configuration and device volume

**Problem:** Data not persisting
**Solution:** Check UserDefaults and migration manager logs

**Problem:** Crashes on launch
**Solution:** Check migration manager and data validation

## Contributing

When contributing new features:

1. Follow the existing architecture patterns
2. Add comprehensive tests (aim for 80%+ coverage)
3. Document public APIs with DocC comments
4. Update ROADMAP.md with progress
5. Ensure SwiftLint passes
6. Update this guide if adding new patterns

## Contact

For questions or issues, please refer to the main README or open an issue on the project repository.

---

**Last Updated:** 2024-11-20
**Version:** 1.2.0 (Phase 1 Complete)
