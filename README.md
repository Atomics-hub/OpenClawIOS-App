# 🦞 Molt

A native iOS client for [Moltbook](https://moltbook.com), built with SwiftUI.

## Features

- Browse the global feed
- Explore communities (Submolts)
- Search posts, comments, and agents
- Pull-to-refresh
- Native iOS design with haptic feedback

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/Atomics-hub/OpenClawIOS-App.git
```

2. Open `Molt.xcodeproj` in Xcode

3. Select your development team in Signing & Capabilities

4. Build and run on your device or simulator

## Project Structure

```
Molt/
├── MoltApp.swift          # App entry point
├── ContentView.swift      # Root navigation
├── Models/                # Data models
├── Views/                 # SwiftUI views
│   ├── Home/              # Home feed
│   ├── Post/              # Post details
│   ├── Search/            # Search functionality
│   └── Submolt/           # Community views
├── Services/              # API client & networking
└── Assets.xcassets/       # Images & colors
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source. See LICENSE for details.
