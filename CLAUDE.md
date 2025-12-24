# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Derby Dash is a local-first, offline-capable Flutter mobile app for managing physical Hot Wheels car tournaments. The app targets children as primary users ("Kid-First" design philosophy), requiring high-contrast UI, large touch targets, and resilience to random tapping.

## Technical Stack

- **Framework:** Flutter (Dart)
- **Database:** Isar (required for relational queries and static typing)
- **State Management:** Riverpod with AsyncNotifier and code generation
- **Image Handling:** `image_picker` + `image_cropper` (1:1 square crop enforced)
- **Navigation:** GoRouter or Navigator 2.0
- **Backend:** None - purely local architecture

## Build Commands

```bash
# Get dependencies
flutter pub get

# Generate Isar schemas and Riverpod code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze
```

## Architecture

### Data Layer (Isar Collections)

Four core entities with specific relationships:

1. **Car** - Individual Hot Wheels cars
   - Uses soft delete (`isDeleted` flag) - never remove records
   - Stats (wins/losses) must be calculated dynamically via queries, never stored

2. **Tournament** - Competition container
   - Status: `setup` → `active` → `completed`
   - Types: `knockout` (single elimination) or `roundRobin`
   - Links to multiple Rounds

3. **Round** - Groups matches within a tournament
   - Sequential numbering (1, 2, 3...)
   - Links to multiple Matches

4. **Match** - Individual race between two cars
   - `carB` nullable for bye matches
   - `winner` nullable until match completed

### Tournament Logic

The `TournamentService` handles bracket generation and match progression:

- **Knockout:** Shuffle cars, pair into matches, handle odd numbers with byes
- **Round Robin:** Every car races every other car once
- Match completion triggers automatic next-round generation when current round finishes

### Key Implementation Rules

1. **Bye Handling:** When odd cars exist, one gets a bye (auto-advance). Show acknowledgment screen requiring tap to continue - never auto-skip.

2. **Undo Logic:** Only affects current match state (clears winner), does not navigate to previous matches.

3. **App Resume:** Always return to Tournament Dashboard on restart, not the specific match screen.

4. **Image Flow:** Camera → 1:1 crop editor → name entry → save. Square format is mandatory.

5. **Garage Display:** Filter by `isDeleted == false` only.
