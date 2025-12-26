# Changelog

All notable changes to Derby Dash will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-01

### Added

#### Tournament System
- Single Elimination (Knockout) tournaments
- Round Robin tournaments
- Group Stage + Knockout combined tournaments
- Best-of-X series support for competitive matches
- Live bracket visualization with real-time updates
- Proper knockout round naming (Quarterfinals, Semifinals, Finals)
- Champion celebration screen

#### Car Garage
- Add cars with camera photos (1:1 square crop)
- Edit car names and photos
- Car detail screen with large photo and stats
- Search functionality
- Sort by wins, name, or date added
- Soft delete (cars preserved for match history)
- Tournament wins tracking

#### Match System
- Visual match screen with car photos
- Winner selection with confirmation
- Bye match handling with acknowledgment screen
- Match history preservation

#### User Experience
- Kid-First design with large touch targets
- High contrast UI
- Keep screen on option during tournaments
- Advanced mode setting for power users
- Fully offline operation

### Technical
- Isar database for local storage
- Riverpod state management with code generation
- Image picker with square cropping

## [Unreleased]

### Planned
- Tournament statistics and analytics
- Export/import car collection
- Multiple tournament formats
