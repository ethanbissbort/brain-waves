# Brain Waves - iOS Binaural Beats & Isochronic Tones App

An iOS application for generating binaural beats and isochronic tones for therapeutic and meditative purposes.

## Features

### Audio Generation
- **Binaural Beats**: Generate two slightly different frequencies (one per stereo channel) to create perceived beat frequencies in your brain
- **Isochronic Tones**: Generate rhythmic pulsing tones that don't require stereo headphones
- Customizable frequency ranges appropriate for therapeutic use (0.5-100 Hz)

### Frequency Ranges & Benefits
- **Delta (0.5-4 Hz)**: Deep sleep, healing, and regeneration
- **Theta (4-8 Hz)**: Meditation, creativity, and deep relaxation
- **Alpha (8-14 Hz)**: Relaxation, stress reduction, and light meditation
- **Beta (14-30 Hz)**: Focus, concentration, and alertness
- **Gamma (30-100 Hz)**: Peak awareness and cognitive enhancement

### User Interface
- Dual input method for frequency selection:
  - Slider controls for intuitive adjustment
  - Numeric text input fields for precise values
- Real-time display of current frequency settings and brainwave type
- Play/pause/stop controls
- Timer with preset options (5, 10, 15, 30, 60 minutes) and custom duration
- Progress indicator showing elapsed and remaining time

### Presets & Playlists
- Save custom frequency configurations with personalized names
- Built-in default presets for common therapeutic uses
- Create playlists combining multiple presets
- Drag-and-drop reordering of playlist items
- Sequential playback of playlist items

### Background Audio
- Play alongside other apps (music players, white noise generators, etc.)
- Continues playback with screen locked
- Handles audio interruptions gracefully (phone calls, alarms)
- Proper AVAudioSession configuration for optimal audio mixing

## Technical Details

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Low-level audio generation and session management
- **Combine**: Reactive programming for state management
- **UserDefaults**: Data persistence for presets and playlists

### Architecture
- **MVVM Pattern**: Clear separation between views, view models, and models
- **Audio Engines**: Separate generators for binaural beats and isochronic tones
- **Session Manager**: Centralized audio session configuration and interruption handling
- **Preset Store**: Centralized data persistence layer

### Audio Implementation
- Real-time sine wave generation using AVAudioEngine
- PCM buffer scheduling for smooth, glitch-free playback
- Proper stereo panning for binaural beats
- Amplitude modulation for isochronic tones
- Background audio capability enabled

## Project Structure

```
BrainWaves/
├── BrainWavesApp.swift              # App entry point
├── ContentView.swift                 # Main tab view
├── Models/
│   ├── BinauralBeatPreset.swift     # Binaural beat data model
│   ├── IsochronicTonePreset.swift   # Isochronic tone data model
│   └── Playlist.swift               # Playlist data model
├── Audio/
│   ├── AudioSessionManager.swift    # Audio session configuration
│   ├── BinauralBeatsGenerator.swift # Binaural beats audio engine
│   └── IsochronicTonesGenerator.swift # Isochronic tones audio engine
├── ViewModels/
│   ├── BinauralBeatsViewModel.swift # Binaural beats state management
│   ├── IsochronicTonesViewModel.swift # Isochronic tones state management
│   └── PlaylistViewModel.swift      # Playlist state management
├── Views/
│   ├── BinauralBeatsView.swift      # Binaural beats UI
│   ├── IsochronicTonesView.swift    # Isochronic tones UI
│   ├── PresetsView.swift            # Presets library UI
│   ├── PlaylistView.swift           # Playlists UI
│   └── Components/
│       ├── FrequencyControl.swift   # Reusable frequency input
│       ├── TimerControl.swift       # Reusable timer UI
│       └── PlaybackControls.swift   # Reusable playback buttons
└── Persistence/
    └── PresetStore.swift            # Data persistence layer
```

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/brain-waves.git
   cd brain-waves
   ```

2. Open the Xcode project:
   ```bash
   open BrainWaves/BrainWaves.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run (⌘R)

## Usage

### Generating Binaural Beats
1. Navigate to the "Binaural Beats" tab
2. Adjust the base frequency (carrier wave)
3. Adjust the beat frequency (perceived frequency)
4. Set your desired duration
5. Press play and use stereo headphones for best results

### Generating Isochronic Tones
1. Navigate to the "Isochronic Tones" tab
2. Adjust the carrier frequency
3. Adjust the pulse frequency
4. Set your desired duration
5. Press play (no stereo headphones required)

### Creating Presets
1. Configure your desired settings
2. Tap "Save as Preset"
3. Enter a name for your preset
4. Find it later in the "Presets" tab

### Creating Playlists
1. Navigate to the "Playlists" tab
2. Tap the "+" button to create a new playlist
3. Enter a name for your playlist
4. Add presets from your library
5. Reorder items by entering edit mode
6. Play the entire playlist sequentially

## Safety Notes

- Start with lower volumes and adjust as needed
- Do not use while driving or operating machinery
- Not recommended for individuals with epilepsy or seizure disorders
- Consult a healthcare professional if you have any concerns
- These tones are for relaxation and focus purposes only

## Documentation

For detailed technical documentation, see [Claude.md](Claude.md)

## Future Enhancements

- Volume fade in/out
- Multiple simultaneous tones
- Custom waveforms (square, triangle, sawtooth)
- Frequency sweeping over time
- iCloud sync for presets
- Dark mode optimization
- Widget for quick access
- Usage analytics and session history

## License

[Specify your license here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.