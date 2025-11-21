# 🧠 Brain Waves - Advanced Binaural Beats & Isochronic Tones

<div align="center">

**A professional iOS application for therapeutic brainwave entrainment**

[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Generate binaural beats and isochronic tones for meditation, focus, sleep, and cognitive enhancement.

</div>

---

## ✨ Feature Highlights

### 🎵 Advanced Audio Generation
- **7 Waveform Types**: Sine, Square, Triangle, Sawtooth, White/Pink/Brown Noise
- **Binaural Beats**: Stereo frequency difference for brainwave entrainment
- **Isochronic Tones**: Rhythmic pulsing (no headphones required)
- **Frequency Ramping**: Gradual frequency changes over time with 5 ramp patterns
- **Volume Control**: Real-time adjustment with fade-in/fade-out effects
- **Background Playback**: Continues with screen locked

### 📊 Enhanced Timer System
- **3 Display Modes**: Compact, Circular (beautiful progress ring), Large (72pt countdown)
- **Color-Coded Progress**: Blue → Green → Orange → Red stages
- **Smart Milestones**: Haptic feedback at 10, 5, 3, 2, 1 minutes and 30 seconds
- **Visual Alerts**: Slide-up notifications with auto-dismiss
- **Local Notifications**: Background alerts when app is inactive
- **Session Completion**: Dual haptic feedback + visual + notification

### 🏷️ Intelligent Organization
- **8 Preset Categories**: Sleep, Meditation, Focus, Relaxation, Creativity, Energy, Study, Custom
- **Flexible Tag System**: Multiple tags per preset for advanced filtering
- **Color-Coded Categories**: Visual identification with unique colors and SF Symbols
- **Smart Filtering**: Find presets by category, tags, or name

### 📤 Import/Export System
- **JSON Export**: Share presets as structured data
- **Text Export**: Human-readable format for documentation
- **AirDrop/Messages**: Native iOS share sheet integration
- **File Import**: Load presets from .json files or clipboard
- **Batch Operations**: Export/import multiple presets at once
- **Community Ready**: Share and discover presets

### ⚡ Quick Actions
- **Home Screen Shortcuts**: 3D Touch/Haptic Touch integration
  - Resume Last Session
  - Start Meditation (10 Hz Alpha)
  - Start Focus Session (20 Hz Beta)
  - Start Sleep Session (2 Hz Delta)
- **Deep Linking**: Instant session start from home screen

### 🎛️ Professional Controls
- **Frequency Ramping**: 5 ramp types (Ascending, Descending, Ascending-Descending, etc.)
- **3 Ramp Curves**: Linear, Exponential, Logarithmic
- **Visual Preview**: See frequency path before starting
- **Real-time Updates**: Smooth frequency transitions during playback

---

## 🌟 What Makes Brain Waves Special

### Scientifically Grounded
- **Brainwave Frequency Ranges**:
  - **Delta (0.5-4 Hz)**: Deep sleep, healing, regeneration
  - **Theta (4-8 Hz)**: Meditation, creativity, deep relaxation
  - **Alpha (8-14 Hz)**: Relaxation, stress reduction, flow state
  - **Beta (14-30 Hz)**: Focus, concentration, alertness
  - **Gamma (30-100 Hz)**: Peak awareness, cognitive enhancement

### Production-Quality Audio
- Real-time waveform generation using AVAudioEngine
- High-fidelity 44.1 kHz sample rate
- Glitch-free PCM buffer scheduling
- Proper stereo panning and amplitude modulation
- Advanced noise generation algorithms (pink noise uses 7-pole IIR filter)

### User Experience Excellence
- **SwiftUI**: Modern, responsive interface
- **Haptic Feedback**: Tactile confirmation for all actions
- **Accessibility**: VoiceOver ready, Dynamic Type support
- **Dark Mode**: Automatic theme adaptation
- **No Ads**: Distraction-free experience

---

## 📱 Feature Deep Dive

### Audio Waveforms

#### Pure Tones
- **Sine Wave**: Smooth, traditional binaural beats
- **Square Wave**: Sharp, intense stimulation
- **Triangle Wave**: Smooth, mellow alternative
- **Sawtooth Wave**: Bright, energetic sound

#### Noise Generators
- **White Noise**: Equal frequency distribution across spectrum
- **Pink Noise**: Natural 1/f spectrum (soothing, like rain)
- **Brown Noise**: Deep, rumbling (Brownian motion)

### Frequency Ramping

Create progressive sessions with automatic frequency changes:

```
Examples:
- Sleep Induction: Start at 10 Hz (Alpha), ramp down to 2 Hz (Delta) over 30 minutes
- Energy Boost: Start at 10 Hz (Alpha), ramp up to 20 Hz (Beta) over 15 minutes
- Meditation Journey: 10 Hz → 6 Hz → 10 Hz (Ascending-Descending pattern)
```

**Ramp Patterns**:
- **Ascending**: Gradually increase frequency
- **Descending**: Gradually decrease frequency
- **Ascending-Descending**: Increase then decrease (meditation arc)
- **Descending-Ascending**: Decrease then increase (rest then energize)
- **None**: Constant frequency

**Curve Types**:
- **Linear**: Steady, even progression
- **Exponential**: Slow start, fast finish
- **Logarithmic**: Fast start, slow finish

### Preset Management

**Default Presets** (10 included):
- Deep Sleep (Delta 2 Hz) - 30 minutes
- Meditation (Theta 6 Hz) - 15 minutes
- Relaxation (Alpha 10 Hz) - 10 minutes
- Focus (Beta 20 Hz) - 30 minutes
- Peak Awareness (Gamma 40 Hz) - 10 minutes
- Deep Relaxation (Delta 3 Hz) - 30 minutes
- Creative Flow (Theta 5 Hz) - 15 minutes
- Calmness (Alpha 10 Hz) - 10 minutes
- Concentration (Beta 18 Hz) - 30 minutes
- High Focus (Gamma 35 Hz) - 10 minutes

**Custom Presets**:
- Save unlimited custom configurations
- Organize with categories and tags
- Export and share with friends
- Import community presets

### Timer Display Modes

#### Compact Mode
- Linear progress bar
- Side-by-side time display
- Minimal vertical space
- Perfect for split-screen

#### Circular Mode ⭐
- Beautiful 200px progress ring
- Large 48pt center countdown
- Smooth animations
- Playing status indicator
- **Most visually appealing**

#### Large Mode
- Massive 72pt countdown
- Detailed statistics
- Horizontal progress bar
- Shows elapsed, duration, progress %
- Perfect for focused sessions

---

## 🏗️ Technical Architecture

### Design Patterns
- **MVVM**: Clear separation of concerns
- **Dependency Injection**: Testable, loosely coupled code
- **Protocol-Oriented**: Flexible, composable components
- **Reactive**: Combine framework for state management

### Core Components

#### Audio Layer
```swift
BaseAudioGenerator (Abstract)
├── BinauralBeatsGenerator
│   ├── Stereo panning (-1.0 left, +1.0 right)
│   ├── Dual AVAudioPlayerNode
│   └── Frequency difference processing
└── IsochronicTonesGenerator
    ├── Amplitude modulation
    ├── Single AVAudioPlayerNode
    └── Pulse frequency control
```

#### State Management
```swift
BaseGeneratorViewModel (Abstract)
├── BinauralBeatsViewModel
│   ├── baseFrequency: Double
│   ├── beatFrequency: Double
│   ├── waveformType: WaveformType
│   ├── rampConfig: FrequencyRampConfig
│   ├── category: PresetCategory
│   └── tags: [String]
└── IsochronicTonesViewModel
    ├── carrierFrequency: Double
    ├── pulseFrequency: Double
    ├── (same additional properties)
    └── ...
```

#### Data Models
```swift
BinauralBeatPreset
├── id: UUID
├── name: String
├── baseFrequency: Double
├── beatFrequency: Double
├── duration: TimeInterval
├── waveformType: WaveformType
├── rampConfig: FrequencyRampConfig?
├── category: PresetCategory
└── tags: [String]

IsochronicTonePreset (similar structure)
```

### Key Systems

#### Error Handling
- Comprehensive error type hierarchy
- User-friendly error messages
- Recovery suggestions
- OSLog integration for debugging

#### Persistence
- UserDefaults for lightweight data
- Codable for type-safe serialization
- Data validation layer
- Migration manager for schema updates
- Backup/restore functionality

#### Utilities
- **HapticManager**: Centralized haptic feedback
- **SettingsManager**: User preferences persistence
- **TimerMilestoneManager**: Smart notification system
- **QuickActionManager**: Home screen shortcuts
- **PresetExporter**: Import/export functionality
- **PresetCoordinator**: Cross-tab preset loading

---

## 📂 Project Structure

```
BrainWaves/
├── 📱 App
│   ├── BrainWavesApp.swift              # Entry point
│   └── ContentView.swift                # Main tab view
│
├── 🎵 Audio
│   ├── AudioGenerator.swift             # Base generator + waveforms
│   ├── BinauralBeatsGenerator.swift     # Binaural beats engine
│   ├── IsochronicTonesGenerator.swift   # Isochronic tones engine
│   └── AudioSessionManager.swift        # Session configuration
│
├── 📊 Models
│   ├── BinauralBeatPreset.swift         # Binaural preset data
│   ├── IsochronicTonePreset.swift       # Isochronic preset data
│   ├── Playlist.swift                   # Playlist data
│   └── FrequencyRamping.swift           # Ramping configuration
│
├── 🎛️ ViewModels
│   ├── BaseGeneratorViewModel.swift     # Shared functionality
│   ├── BinauralBeatsViewModel.swift     # Binaural state
│   ├── IsochronicTonesViewModel.swift   # Isochronic state
│   └── PlaylistViewModel.swift          # Playlist state
│
├── 🎨 Views
│   ├── BinauralBeatsView.swift          # Binaural UI
│   ├── IsochronicTonesView.swift        # Isochronic UI
│   ├── PresetsView.swift                # Presets library
│   ├── PlaylistView.swift               # Playlists
│   └── Components/
│       ├── FrequencyControl.swift       # Frequency input
│       ├── TimerControl.swift           # Timer controls
│       ├── PlaybackControls.swift       # Play/pause/stop
│       ├── VolumeControl.swift          # Volume slider
│       ├── WaveformSelector.swift       # Waveform picker
│       ├── FrequencyRampingControl.swift # Ramping config
│       ├── CategorySelector.swift       # Category/tag picker
│       ├── EnhancedTimerDisplay.swift   # Advanced timer
│       └── PresetImportExportView.swift # Share UI
│
├── 🛠️ Utils
│   ├── AppConstants.swift               # Centralized constants
│   ├── HapticManager.swift              # Haptic feedback
│   ├── SettingsManager.swift            # User preferences
│   ├── PresetCoordinator.swift          # Cross-tab loading
│   ├── TimerMilestoneManager.swift      # Milestone tracking
│   ├── QuickActionManager.swift         # Home screen shortcuts
│   └── PresetExporter.swift             # Import/export
│
├── 💾 Persistence
│   ├── PresetStore.swift                # Data storage
│   ├── DataValidator.swift              # Input validation
│   └── MigrationManager.swift           # Schema migrations
│
├── 🔧 DependencyInjection
│   ├── DependencyContainer.swift        # DI container
│   └── Protocols.swift                  # Protocol definitions
│
└── ⚠️ ErrorHandling
    ├── BrainWavesError.swift            # Error types
    ├── ErrorHandler.swift               # Error presentation
    └── Logger.swift                     # OSLog wrapper
```

---

## 🚀 Getting Started

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- macOS 13.0+ (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ethanbissbort/brain-waves.git
   cd brain-waves
   ```

2. **Open in Xcode**
   ```bash
   cd BrainWaves
   open BrainWaves.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press ⌘R to build and run

### First Launch
1. The app requests notification permissions (for timer completion alerts)
2. Default presets are automatically loaded
3. Quick Actions are registered with iOS
4. You're ready to start your first session!

---

## 📖 Usage Guide

### Quick Start

#### Creating Your First Session

1. **Choose Your Method**
   - **Binaural Beats Tab**: Requires stereo headphones
   - **Isochronic Tones Tab**: Works with speakers or headphones

2. **Configure Settings**
   ```
   Example: Meditation Session
   - Frequency: 10 Hz (Alpha)
   - Waveform: Sine (smooth)
   - Duration: 15 minutes
   - Volume: 30%
   ```

3. **Optional Enhancements**
   - Add frequency ramping for progressive sessions
   - Choose different waveforms for variety
   - Select appropriate category and tags

4. **Start Playing**
   - Tap Play button
   - Timer begins countdown
   - Milestone notifications at intervals
   - Session completes with haptic feedback

### Using Quick Actions

**From Home Screen:**
1. Long press the Brain Waves app icon
2. Select a quick action:
   - **Resume Last Session**: Continue previous settings
   - **Start Meditation**: 10 Hz Alpha, 10 minutes
   - **Start Focus**: 20 Hz Beta, 30 minutes
   - **Start Sleep**: 2 Hz Delta, 30 minutes
3. App opens and session starts automatically

### Creating Custom Presets

1. Configure your desired settings
2. Tap "Save as Preset"
3. Enter preset name
4. Select category (Sleep, Focus, etc.)
5. Add tags (optional, for filtering)
6. Tap Save
7. Find in Presets tab organized by category

### Sharing Presets

#### Export
1. Navigate to Presets tab
2. Tap share icon on preset
3. Choose format:
   - **JSON**: For digital sharing
   - **Text**: Human-readable
4. Share via AirDrop, Messages, Mail, etc.

#### Import
1. Tap Import button
2. Paste JSON or select file
3. Preset appears in your library
4. Ready to use immediately

### Creating Playlists

1. **Playlists Tab** → **+** button
2. Name your playlist
3. Add presets from library
4. Reorder by dragging
5. Tap Play to run sequentially
6. Perfect for:
   - Morning routines
   - Evening wind-down
   - Study sessions
   - Meditation programs

### Frequency Ramping

**Example: Sleep Induction**
```
1. Enable ramping
2. Ramp Type: Descending
3. Curve: Logarithmic (fast start, slow finish)
4. Start: 10 Hz (relaxed Alpha)
5. End: 2 Hz (deep Delta)
6. Duration: 30 minutes
7. Watch preview graph
```

**Example: Energy Boost**
```
1. Enable ramping
2. Ramp Type: Ascending
3. Curve: Exponential (slow start, fast finish)
4. Start: 8 Hz (Alpha)
5. End: 20 Hz (Beta)
6. Duration: 15 minutes
```

---

## 🎓 Understanding Brainwave Frequencies

### Delta Waves (0.5-4 Hz)
- **State**: Deep sleep, unconscious
- **Benefits**: Physical healing, immune system boost, deep rest
- **Use Cases**: Insomnia, deep meditation, recovery
- **Best Time**: Nighttime, pre-sleep

### Theta Waves (4-8 Hz)
- **State**: Light sleep, deep meditation, creativity
- **Benefits**: Enhanced intuition, creativity, emotional processing
- **Use Cases**: Meditation, hypnosis, creative work, memory
- **Best Time**: Morning meditation, creative sessions

### Alpha Waves (8-14 Hz)
- **State**: Relaxed awareness, flow state
- **Benefits**: Stress reduction, mental clarity, learning
- **Use Cases**: Study, light meditation, stress relief
- **Best Time**: Any time, especially during study

### Beta Waves (14-30 Hz)
- **State**: Active thinking, focus, alertness
- **Benefits**: Enhanced concentration, problem-solving, alertness
- **Use Cases**: Work, study, complex tasks
- **Best Time**: Daytime, during focused work

### Gamma Waves (30-100 Hz)
- **State**: Peak awareness, high-level cognition
- **Benefits**: Enhanced perception, consciousness, insight
- **Use Cases**: Peak performance, cognitive enhancement
- **Best Time**: Short bursts during important tasks

---

## 🔬 Development Status

### ✅ Phase 1: Foundation (COMPLETED)
- [x] Core audio generation (binaural beats & isochronic tones)
- [x] MVVM architecture with base classes
- [x] Constants centralization
- [x] Protocol-based audio generators
- [x] Timer system with presets
- [x] Preset management & persistence
- [x] Playlist functionality
- [x] Background audio support
- [x] Volume control with fade effects
- [x] Preset loading across tabs
- [x] Dependency injection system
- [x] Comprehensive error handling
- [x] Enhanced persistence layer
- [x] Unit & UI test suite (80%+ coverage)
- [x] SwiftLint integration
- [x] Complete API documentation

### ✅ Phase 2: Advanced Features (COMPLETED)
- [x] 7 waveform types (sine, square, triangle, sawtooth, noise)
- [x] Frequency ramping (5 patterns, 3 curves)
- [x] Preset categories (8 categories with color coding)
- [x] Flexible tag system
- [x] Import/export functionality (JSON & text)
- [x] Enhanced timer display (3 modes)
- [x] Milestone tracking & notifications
- [x] Quick Actions (home screen shortcuts)
- [x] Share sheet integration
- [x] Deep linking support

### 🚧 Phase 3: Advanced Features (PLANNED)
- [ ] Multi-layer audio (mix multiple tones)
- [ ] Audio effects (reverb, echo, filters, chorus)
- [ ] Real-time waveform visualization
- [ ] Gesture controls (swipe, pinch, double-tap)
- [ ] Advanced playlist features (shuffle, repeat, crossfade)
- [ ] Smart playlists (auto-generate by mood/time)
- [ ] Session history & analytics
- [ ] HealthKit integration
- [ ] iCloud sync
- [ ] Apple Watch companion app

### 🎯 Phase 4: Monetization (FUTURE)
- [ ] Freemium model with premium features
- [ ] Expert preset packs
- [ ] Subscription tier
- [ ] Community preset marketplace

---

## ⚠️ Safety & Disclaimer

### Important Safety Information
- ⚠️ **Do not use while driving or operating machinery**
- ⚠️ **Not recommended for individuals with epilepsy or seizure disorders**
- ⚠️ **Consult healthcare professional if you have concerns**
- ⚠️ **Start with lower volumes and adjust gradually**
- ⚠️ **Not a medical device or treatment**

### Best Practices
- Use comfortable volume levels (never painful)
- Take breaks during long sessions
- Stay hydrated
- Create a comfortable environment
- Use quality headphones for binaural beats
- Avoid use before important decisions
- Stop if you feel uncomfortable

### Clinical Note
These tones are for **relaxation, focus, and meditation purposes only**. They are not intended to diagnose, treat, cure, or prevent any disease. Results vary by individual. This app is not a substitute for professional medical advice.

---

## 🧪 Testing

### Running Tests
```bash
# Unit Tests
⌘U in Xcode

# UI Tests
⌘U with UI Test target selected

# Coverage Report
Coverage target: 80%+ maintained
```

### Test Structure
```
BrainWavesTests/
├── Audio/
│   └── AudioGeneratorTests.swift
├── ViewModels/
│   └── BaseGeneratorViewModelTests.swift
├── Models/
│   └── PresetTests.swift
└── Persistence/
    └── DataValidatorTests.swift
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to help:

### Priority Areas
1. **Audio Research**: Scientific validation of frequency ranges
2. **Preset Creation**: Expert-designed therapeutic presets
3. **Translations**: Localization to new languages
4. **Testing**: Beta testing and bug reporting
5. **Feature Requests**: User feedback and suggestions

### Development Process
1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### Code Standards
- Follow SwiftLint rules (`.swiftlint.yml`)
- Write unit tests for new features
- Add DocC documentation
- Follow MVVM architecture
- Use protocol-oriented design

---

## 📚 Additional Resources

### Scientific References
- [Binaural Beats Research on PubMed](https://pubmed.ncbi.nlm.nih.gov/?term=binaural+beats)
- [Brainwave Entrainment Studies](https://scholar.google.com/scholar?q=brainwave+entrainment)
- [Alpha Wave Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3111147/)

### Technical Documentation
- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [Audio Session Programming Guide](https://developer.apple.com/documentation/avfaudio/avaudiosession)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Developer Guide
See [DEVELOPER.md](DEVELOPER.md) for:
- Architecture deep dive
- Code organization
- Testing guidelines
- Contribution workflow

### Roadmap
See [ROADMAP.md](ROADMAP.md) for:
- Completed features
- Planned enhancements
- Timeline & priorities
- Success metrics

---

## 📄 License

[MIT License](LICENSE) - See LICENSE file for details

Copyright (c) 2024 Brain Waves Development Team

---

## 🙏 Acknowledgments

- SwiftUI community for excellent tutorials
- AVFoundation documentation and examples
- Scientific research community for brainwave frequency data
- Beta testers for valuable feedback
- Open source contributors

---

## 📧 Support

### Get Help
- 📖 [Documentation](docs/)
- 🐛 [Report Bug](https://github.com/ethanbissbort/brain-waves/issues)
- 💡 [Request Feature](https://github.com/ethanbissbort/brain-waves/issues)
- 💬 [Discussions](https://github.com/ethanbissbort/brain-waves/discussions)

### Contact
- GitHub: [@ethanbissbort](https://github.com/ethanbissbort)
- Project: [Brain Waves Repository](https://github.com/ethanbissbort/brain-waves)

---

<div align="center">

**Made with ❤️ for mindfulness and productivity**

⭐ Star this repo if you find it helpful!

[Report Bug](https://github.com/ethanbissbort/brain-waves/issues) · [Request Feature](https://github.com/ethanbissbort/brain-waves/issues) · [Documentation](docs/)

</div>
