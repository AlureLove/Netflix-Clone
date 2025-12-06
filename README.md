# Netflix Clone

An iOS Netflix clone application built with Swift and UIKit, featuring movie browsing, video playback, danmaku (bullet comments), subtitles, and more.

## Features

### Core Functionality
- **Movie Browsing**: Browse trending, upcoming, and top-rated movies and TV shows
- **Search**: Real-time search for movies and TV shows
- **Video Preview**: Watch movie trailers
- **Download Management**: Manage downloaded movie content

### Advanced Video Player
- **Playback Controls**
  - Play/Pause
  - Seekable progress bar
  - Playback speed control (0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x)
  - Time display (current/duration)

- **Display Features**
  - Subtitle support
  - Danmaku system (similar to Bilibili)
  - Danmaku input and sending

- **Playback Modes**
  - Fullscreen/Portrait switching
  - Auto-rotation support
  - Picture-in-Picture (PiP) mode
  - Background playback support

- **Gesture Controls**
  - Swipe left side up/down to adjust brightness
  - Swipe right side up/down to adjust volume
  - Single tap to show/hide controls

- **Video Caching**
  - Automatic video cache management
  - Offline playback support

## Tech Stack

- **Language**: Swift
- **UI Framework**: UIKit
- **Architecture**: MVC
- **Networking**: URLSession + async/await
- **Video Playback**: AVFoundation, AVKit
- **Data Persistence**: Core Data (for download management)

## API Integration

This project integrates the following APIs:

1. **The Movie Database (TMDB) API**
   - Fetch movie and TV show information
   - Get trending, upcoming, and top-rated content

2. **YouTube Data API**
   - Fetch movie trailer videos

3. **Pexels API**
   - Get high-quality sample video content

## Project Structure

```
Netflix Clone/
├── iOS/
│   └── Netflix Clone/
│       ├── Controllers/
│       │   ├── Core/                    # Main view controllers
│       │   │   ├── HomeViewController.swift
│       │   │   ├── SearchViewController.swift
│       │   │   ├── UpcomingViewController.swift
│       │   │   └── DownloadViewController.swift
│       │   └── General/                 # General controllers
│       │       ├── SearchResultsViewController.swift
│       │       ├── TitlePreviewViewController.swift
│       │       └── CustomVideoPlayerViewController.swift
│       ├── Views/                       # Custom views
│       │   ├── TitleCollectionViewCell.swift
│       │   ├── TitleTableViewCell.swift
│       │   ├── HeroHeaderUIView.swift
│       │   ├── SubtitleView.swift
│       │   ├── DanmakuView.swift
│       │   └── CollectionViewTableViewCell.swift
│       ├── ViewModels/                  # View models
│       │   ├── TitleViewModel.swift
│       │   └── TitlePreviewViewModel.swift
│       ├── Models/                      # Data models
│       │   ├── Movie.swift
│       │   ├── YoutubeSearchResponse.swift
│       │   └── PexelsModels.swift
│       ├── Managers/                    # Managers
│       │   ├── APICaller.swift
│       │   ├── PexelsAPIManager.swift
│       │   ├── VideoCacheManager.swift
│       │   └── APIKeys.swift
│       └── Resources/
│           └── Extensions.swift
```

## Installation & Setup

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/AlureLove/Netflix-Clone.git
cd Netflix-Clone
```

2. **Configure API Keys**

Create the `APIKeys.swift` file in the project and add your API keys:

```swift
struct APIKeys {
    static let tmdbBearerToken = "YOUR_TMDB_BEARER_TOKEN"
    static let YouTubeAPIKey = "YOUR_YOUTUBE_API_KEY"
    static let pexelsAPIKey = "YOUR_PEXELS_API_KEY"
}
```

Get your API keys:
- **TMDB API**: Visit [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api) to sign up and get your Bearer Token
- **YouTube Data API**: Visit [https://console.developers.google.com/](https://console.developers.google.com/) to create a project and enable YouTube Data API v3
- **Pexels API**: Visit [https://www.pexels.com/api/](https://www.pexels.com/api/) to sign up and get your API Key

3. **Open the project**
```bash
cd iOS/Netflix\ Clone
open Netflix\ Clone.xcodeproj
```

4. **Run the project**
- Select a target device or simulator
- Press the Run button (⌘ + R)

## Main Features

### Home
- Featured movie Hero Banner
- Category sections: Trending Movies, Trending TV Shows, Upcoming, Top Rated, etc.
- Horizontal scrolling for each category

### Search
- Real-time movie and TV show search
- Grid display of search results
- Tap to view details

### Upcoming
- List view of upcoming movies
- Display movie poster, title, and description
- Tap to play trailer

### Downloads
- Manage saved movies
- Delete downloaded content
- Offline playback support

### Video Player

The player provides rich functionality:

#### Basic Controls
- Play/Pause button
- Draggable progress bar
- Time display
- Playback speed toggle

#### Advanced Features
- **Subtitles**: Tap subtitle button to toggle subtitle display
- **Danmaku**:
  - Tap danmaku button to open input field
  - Enter text and send danmaku
  - Danmaku scrolls from right to left across the screen
- **Picture-in-Picture**: Support iOS PiP mode, continue watching while using other apps
- **Fullscreen**: Support landscape/portrait switching, auto-fullscreen in landscape

#### Gesture Controls
- **Single Tap**: Show/hide playback controls
- **Left Side Swipe Up/Down**: Adjust screen brightness
- **Right Side Swipe Up/Down**: Adjust system volume

## Key Implementation Features

### Async Network Requests
Uses Swift's async/await pattern for network requests:
```swift
func getTrendingMovies() async throws -> [Title]
```

### Video Caching
Implements intelligent video caching system to enhance user experience:
- Automatic caching of played videos
- Cache size management
- Offline playback support

### Danmaku System
Bilibili-style danmaku functionality:
- Multi-lane danmaku display
- Collision avoidance algorithm
- Customizable danmaku color, size, and speed

### Picture-in-Picture Support
Complete PiP functionality:
- Automatic PiP (when app enters background)
- Manual PiP toggle
- PiP state monitoring and handling

## Dark Mode

The app supports dark mode and automatically adapts to system settings.

## Contributing

Issues and Pull Requests are welcome!

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is for learning and demonstration purposes only.

## Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) - Movie data provider
- [YouTube Data API](https://developers.google.com/youtube/v3) - Video preview provider
- [Pexels](https://www.pexels.com/) - Sample video content provider

## Author

Jethro Liu

## Changelog

- **v1.0.0** - Initial release
  - Basic movie browsing functionality
  - Search and download features
  - Basic video player

- **v1.1.0** - Player enhancement
  - Added custom video player
  - Subtitle and danmaku support
  - Picture-in-Picture mode
  - Gesture control features
  - Video caching system
