# Brain Waves - iOS Binaural Beats & Isochronic Tones App

## Project Overview

Brain Waves is an iOS application designed to generate and play binaural beats and isochronic tones for therapeutic and meditative purposes. The app provides precise frequency control, preset management, and playlist functionality, all while supporting background audio mixing with other applications.

## Recent Refactorings (v1.1)

### Code Quality Improvements

**1. Constants Centralization** (`AppConstants.swift`)
- Extracted all magic numbers and hardcoded values into a centralized constants file
- Organized constants by domain: Audio, Timer, UI, Storage, and Brainwave types
- Improved code maintainability and consistency
- Made it easier to adjust configuration values globally

**2. Protocol-Based Architecture** (`AudioGenerator.swift`)
- Created `AudioGenerator` protocol to define common audio generator interface
- Implemented `BaseAudioGenerator` base class with shared functionality
- Reduced code duplication between `BinauralBeatsGenerator` and `IsochronicTonesGenerator`
- Improved testability through protocol-oriented design

**3. View Model Refactoring** (`BaseGeneratorViewModel.swift`)
- Created base view model class with common state management logic
- Eliminated duplicate code in view models
- Centralized timer formatting and progress calculation
- Simplified view model implementations

**4. Error Handling**
- Added `AudioGeneratorError` enum for typed error handling
- Improved error messages for debugging
- Prepared foundation for user-facing error displays

### Benefits Achieved

- **Reduced Code Duplication**: Eliminated ~200 lines of duplicate code
- **Improved Maintainability**: Centralized configuration makes changes easier
- **Better Testability**: Protocol-based design enables easier unit testing
- **Scalability**: Adding new audio generators is now simpler
- **Consistency**: Shared constants ensure UI/behavior consistency

## Architecture

### Core Components

#### 1. Audio Engine (`AudioEngine.swift`)
- **Purpose**: Manages low-level audio generation using AVFoundation
- **Key Responsibilities**:
  - Generate binaural beats (stereo frequency differential)
  - Generate isochronic tones (amplitude-modulated pulses)
  - Configure AVAudioEngine with proper nodes and format
  - Handle audio session lifecycle
  - Support background audio playback

#### 2. Audio Session Manager (`AudioSessionManager.swift`)
- **Purpose**: Configure AVAudioSession for optimal audio mixing
- **Key Responsibilities**:
  - Set audio session category to `.playback` with `.mixWithOthers` option
  - Handle audio interruptions (phone calls, alarms, etc.)
  - Restore playback after interruptions when appropriate
  - Manage audio route changes

#### 3. Data Models
- **`BinauralBeatPreset`**: Stores configuration for binaural beats
  - Base frequency (carrier frequency)
  - Beat frequency (difference between left/right channels)
  - Duration
  - Custom name
- **`IsochronicTonePreset`**: Stores configuration for isochronic tones
  - Carrier frequency
  - Pulse frequency
  - Duration
  - Custom name
- **`Playlist`**: Collection of presets with ordering
  - Name
  - Array of preset references
  - Playback order

#### 4. Persistence Layer (`PresetStore.swift`)
- **Purpose**: Save and load user presets and playlists
- **Implementation**: UserDefaults with Codable protocols
- **Data Stored**:
  - User-created presets
  - Custom playlists
  - Last used settings

#### 5. SwiftUI Views

**Main View (`ContentView.swift`)**
- Tab-based navigation between:
  - Binaural Beats generator
  - Isochronic Tones generator
  - Presets library
  - Playlists

**Generator Views**
- Dual input method for frequency selection:
  - Slider controls for intuitive adjustment
  - Text fields for precise numeric input
- Real-time frequency display
- Play/Pause/Stop controls
- Timer controls with presets (5min, 10min, 15min, 30min, 60min, custom)
- Save preset button

**Presets View**
- List of saved presets
- Load preset action
- Delete preset action
- Edit preset name

**Playlist View**
- Create new playlists
- Add presets to playlists
- Drag-and-drop reordering (using `.onMove` modifier)
- Play playlist sequentially
- Progress indicator

## Audio Generation Details

### Binaural Beats
```
Left Channel:  Base Frequency (e.g., 200 Hz)
Right Channel: Base Frequency + Beat Frequency (e.g., 200 Hz + 10 Hz = 210 Hz)
Result:        Perceived 10 Hz beat in the brain
```

**Therapeutic Frequency Ranges**:
- Delta (0.5-4 Hz): Deep sleep, healing
- Theta (4-8 Hz): Meditation, creativity
- Alpha (8-14 Hz): Relaxation, stress reduction
- Beta (14-30 Hz): Focus, concentration
- Gamma (30-100 Hz): Peak awareness, cognitive enhancement

**Implementation**:
- Use AVAudioPlayerNode for each channel
- Generate sine wave buffers with PCM format
- Pan each player to extreme left/right
- Base frequency range: 100-500 Hz
- Beat frequency range: 0.5-100 Hz

### Isochronic Tones
```
Single tone at carrier frequency
Amplitude modulated at pulse frequency
Result: Rhythmic pulsing that doesn't require stereo headphones
```

**Implementation**:
- Single AVAudioPlayerNode
- Apply amplitude modulation to sine wave
- Modulation creates on/off pulsing effect
- Carrier frequency range: 100-500 Hz
- Pulse frequency range: 0.5-100 Hz

## Technical Implementation

### AVFoundation Setup

```swift
// Audio Session Configuration
AVAudioSession.sharedInstance().setCategory(
    .playback,
    mode: .default,
    options: [.mixWithOthers]
)

// Audio Engine Structure
AVAudioEngine
  ├── AVAudioPlayerNode (Left channel for binaural)
  ├── AVAudioPlayerNode (Right channel for binaural)
  ├── AVAudioMixerNode
  └── Output Node
```

### Buffer Generation Strategy
- Pre-generate audio buffers in chunks (0.5-1 second)
- Schedule buffers in advance to prevent dropouts
- Use completion handlers to schedule next buffer
- Maintain circular buffer queue for smooth playback

### Background Audio
- Add "Audio, AirPlay, and Picture in Picture" capability
- Configure audio session before starting playback
- Handle interruptions in AudioSessionManager
- Test with other apps (Music, Podcasts, etc.)

## User Interface Design

### Frequency Input Pattern
```
[Label: Base Frequency]
[Slider: 100 ----------------o---- 500 Hz]
[TextField: 250 Hz]

Benefits:
- Slider: Quick, visual adjustment
- TextField: Precise numeric entry
- Bidirectional binding: Changes sync both ways
```

### Timer Interface
```
Duration: [5m] [10m] [15m] [30m] [60m] [Custom]
Remaining: 14:23
[Progress Bar]
```

### Playlist Drag-and-Drop
```swift
List {
    ForEach(playlistItems) { item in
        PlaylistRow(item: item)
    }
    .onMove { from, to in
        playlistItems.move(fromOffsets: from, toOffset: to)
    }
}
.environment(\.editMode, .constant(.active))
```

## Data Persistence

### UserDefaults Keys
- `saved_binaural_presets`: Array of BinauralBeatPreset
- `saved_isochronic_presets`: Array of IsochronicTonePreset
- `playlists`: Array of Playlist
- `last_used_settings`: Dictionary of last session state

### Codable Implementation
```swift
struct BinauralBeatPreset: Codable, Identifiable {
    let id: UUID
    var name: String
    var baseFrequency: Double
    var beatFrequency: Double
    var duration: TimeInterval
}
```

## File Structure

```
BrainWaves/
├── BrainWavesApp.swift              # App entry point
├── ContentView.swift                 # Main tab view
├── Models/
│   ├── BinauralBeatPreset.swift
│   ├── IsochronicTonePreset.swift
│   └── Playlist.swift
├── Audio/
│   ├── AudioEngine.swift
│   ├── AudioSessionManager.swift
│   ├── BinauralBeatsGenerator.swift
│   └── IsochronicTonesGenerator.swift
├── ViewModels/
│   ├── BinauralBeatsViewModel.swift
│   ├── IsochronicTonesViewModel.swift
│   └── PlaylistViewModel.swift
├── Views/
│   ├── BinauralBeatsView.swift
│   ├── IsochronicTonesView.swift
│   ├── PresetsView.swift
│   ├── PlaylistView.swift
│   └── Components/
│       ├── FrequencyControl.swift
│       ├── TimerControl.swift
│       └── PlaybackControls.swift
├── Persistence/
│   └── PresetStore.swift
└── Info.plist                        # Background audio capability
```

## Testing Checklist

### Audio Generation
- [ ] Binaural beats produce correct frequency differential
- [ ] Isochronic tones pulse at correct rate
- [ ] No audio glitches or dropouts
- [ ] Smooth transitions between frequencies
- [ ] Proper stereo separation for binaural beats

### Background Audio
- [ ] Plays alongside Music app
- [ ] Plays alongside white noise apps
- [ ] Continues during screen lock
- [ ] Handles phone call interruptions
- [ ] Resumes after alarm interruptions

### User Interface
- [ ] Slider and text field stay synchronized
- [ ] Invalid text input handled gracefully
- [ ] All frequency ranges properly constrained
- [ ] Timer counts down accurately
- [ ] Timer stops playback at zero

### Presets & Playlists
- [ ] Presets save and load correctly
- [ ] Playlist reordering works smoothly
- [ ] Deleted items don't reappear
- [ ] Data persists across app restarts
- [ ] Playlist plays presets in correct order

## Future Enhancements

1. **Advanced Features**
   - Volume fade in/out
   - Multiple simultaneous tones
   - Custom waveforms (square, triangle, sawtooth)
   - Frequency sweeping over time

2. **User Experience**
   - Dark mode optimization
   - Haptic feedback
   - Widget for quick access
   - Siri shortcuts integration

3. **Social & Cloud**
   - iCloud sync for presets
   - Share presets with other users
   - Community preset library

4. **Analytics & Insights**
   - Usage tracking
   - Session history
   - Favorite presets analytics

## Resources

### Audio Programming
- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/)

### Binaural Beats Research
- Frequency ranges and therapeutic applications
- Scientific studies on effectiveness
- Best practices for safe listening levels

### SwiftUI
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- List and drag-and-drop patterns
- State management best practices

## License

[Specify your license here]

## Contributing

[Specify contribution guidelines here]
