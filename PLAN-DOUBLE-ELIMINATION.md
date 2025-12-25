# Double Elimination Tournament - Implementation Plan

## Overview

Double elimination gives every participant a second chance. A car must lose **twice** to be eliminated. This creates two parallel brackets that eventually merge.

```
WINNER'S BRACKET                         LOSER'S BRACKET

R1        R2        Finals               L-R1      L-R2      L-Finals
┌───┐
│ A │──┐
└───┘  │  ┌───┐                          ┌───┐
       ├──│A/B│──┐                       │   │──┐
┌───┐  │  └───┘  │                       └───┘  │  ┌───┐
│ B │──┘         │  ┌─────┐                     ├──│   │──┐
└───┘            ├──│W-Fin│                     │  └───┘  │
┌───┐            │  └─────┘              ┌───┐  │         │  ┌─────┐
│ C │──┐         │     │                 │   │──┘         ├──│L-Fin│
└───┘  │  ┌───┐  │     │                 └───┘            │  └─────┘
       ├──│C/D│──┘     ▼                                  │     │
┌───┐  │  └───┘    ┌───────┐             Losers from      │     │
│ D │──┘     │     │ GRAND │             Winner's R1      │     │
└───┘        │     │ FINAL │◄────────────────────────────────────┘
             │     └───────┘
             │         ▲
             └─────────┘
         Losers drop to
         Loser's Bracket
```

---

## Current Architecture Analysis

### Data Models

**Tournament** (`lib/data/models/tournament.dart`)
```dart
enum TournamentType { knockout, roundRobin }  // Need to add: doubleElimination
```

**Round** (`lib/data/models/round.dart`)
```dart
class Round {
  int roundNumber;      // Sequential within tournament
  bool isCompleted;
  // MISSING: No concept of which bracket (winners/losers/grand finals)
}
```

**Match** (`lib/data/models/match.dart`)
```dart
class Match {
  carA, carB, winner, isBye;
  // MISSING: No link to where loser goes, no bracket type indicator
}
```

### Tournament Service

Current `_checkRoundCompletion()` logic:
1. When all matches in round complete → mark round complete
2. Collect winners → create next round with winners
3. If only 1 winner → tournament complete

**Problem**: No concept of parallel brackets or loser tracking.

---

## Design Decisions

### Option A: Extend Existing Models (Recommended)
Add fields to existing models to support double elimination while maintaining backward compatibility.

**Pros**: Less migration work, simpler schema changes
**Cons**: Models become more complex

### Option B: Separate Bracket Entity
Create a new `Bracket` entity between Tournament and Round.

**Pros**: Cleaner separation of concerns
**Cons**: More extensive refactoring, migration complexity

### Recommendation: **Option A** - Extend existing models

---

## Data Model Changes

### 1. Tournament Model

```dart
enum TournamentType {
  knockout,         // Single elimination (existing)
  roundRobin,       // Round robin (existing)
  doubleElimination // NEW
}

@collection
class Tournament {
  Id id = Isar.autoIncrement;
  late DateTime date;
  TournamentStatus status = TournamentStatus.setup;
  late TournamentType type;
  final rounds = IsarLinks<Round>();

  // NEW: For double elimination, track if grand finals reset occurred
  bool grandFinalsReset = false;
}
```

### 2. Round Model

```dart
enum BracketType {
  winners,      // Winner's bracket (also used for single elimination)
  losers,       // Loser's bracket
  grandFinals   // Final match(es) between bracket winners
}

@collection
class Round {
  Id id = Isar.autoIncrement;
  late int roundNumber;
  bool isCompleted = false;
  final matches = IsarLinks<Match>();

  @Backlink(to: 'rounds')
  final tournament = IsarLink<Tournament>();

  // NEW: Which bracket this round belongs to
  @Enumerated(EnumType.name)
  BracketType bracketType = BracketType.winners;

  // NEW: For loser's bracket, which winner's round feeds into this
  int? feedsFromWinnersRound;
}
```

### 3. Match Model

```dart
@collection
class Match {
  Id id = Isar.autoIncrement;
  final carA = IsarLink<Car>();
  final carB = IsarLink<Car>();
  final winner = IsarLink<Car>();
  bool isBye = false;

  @Backlink(to: 'matches')
  final round = IsarLink<Round>();

  // NEW: Position in bracket for loser routing
  int matchPosition = 0;

  // NEW: Link to the loser's bracket match where loser goes (for winner's bracket matches)
  final loserGoesTo = IsarLink<Match>();
}
```

---

## Tournament Service Changes

### New Methods Required

```dart
class TournamentService {
  // Existing methods remain unchanged for knockout/roundRobin

  // NEW: Create double elimination tournament
  Future<int> createDoubleEliminationTournament(List<int> carIds);

  // NEW: Create initial bracket structure
  Future<void> _createDoubleEliminationBrackets(Tournament tournament, List<Car> cars);

  // NEW: Handle match completion for double elimination
  Future<void> _handleDoubleEliminationMatchComplete(Match match);

  // NEW: Route loser to appropriate loser's bracket match
  Future<void> _routeLoserToLosersBracket(Match completedMatch, Car loser);

  // NEW: Check if grand finals needed / bracket reset
  Future<void> _checkGrandFinalsProgression(Tournament tournament);

  // NEW: Get rounds by bracket type
  Future<List<Round>> getRoundsByBracket(int tournamentId, BracketType bracketType);
}
```

### Double Elimination Bracket Generation Algorithm

For N participants:

**Winner's Bracket:**
- Same as single elimination
- Round 1: ceil(N/2) matches
- Each subsequent round: half the matches
- Continue until 1 winner

**Loser's Bracket Structure (complex):**
The loser's bracket has a specific structure where:
1. Losers from Winner's R1 → Loser's R1
2. Losers from Winner's R2 → Feed into Loser's R2 (against L-R1 winners)
3. Pattern continues...

**Simplified Structure for 8 players:**
```
Winner's Bracket:
  W-R1: 4 matches (8→4 players)
  W-R2: 2 matches (4→2 players)
  W-Finals: 1 match (2→1 player) → Winner's Bracket Champion

Loser's Bracket:
  L-R1: 2 matches (4 losers from W-R1, paired → 2 advance)
  L-R2: 2 matches (2 from L-R1 + 2 losers from W-R2 → 2 advance)
  L-R3: 1 match (2→1)
  L-Finals: 1 match (1 from L-R3 + loser from W-Finals → 1) → Loser's Bracket Champion

Grand Finals:
  GF-1: Winner's Bracket Champion vs Loser's Bracket Champion
  GF-2 (if needed): Bracket reset if L-Bracket Champion wins GF-1
```

### Match Completion Flow

```dart
Future<void> completeMatch(int matchId, int winnerId) async {
  final match = await getMatch(matchId);
  final tournament = await getTournamentForMatch(match);

  // Set winner
  match.winner.value = winner;
  await save(match);

  if (tournament.type == TournamentType.doubleElimination) {
    await _handleDoubleEliminationMatchComplete(match, tournament);
  } else {
    await _checkRoundCompletion(matchId); // Existing logic
  }
}

Future<void> _handleDoubleEliminationMatchComplete(Match match, Tournament tournament) async {
  final round = match.round.value!;
  final loser = match.carA.value!.id == match.winner.value!.id
      ? match.carB.value
      : match.carA.value;

  if (round.bracketType == BracketType.winners) {
    // Route loser to loser's bracket
    await _routeLoserToLosersBracket(match, loser!);
    // Advance winner in winner's bracket
    await _advanceWinnerInBracket(match, round);
  } else if (round.bracketType == BracketType.losers) {
    // Loser is eliminated
    // Advance winner in loser's bracket
    await _advanceWinnerInBracket(match, round);
  } else if (round.bracketType == BracketType.grandFinals) {
    await _handleGrandFinalsResult(match, tournament);
  }

  await _checkRoundCompletion(match.id);
}
```

---

## Bracket View Changes

### New Widget Structure

```
DoubleBracketView
├── Column
│   ├── Text("WINNER'S BRACKET")
│   ├── BracketView (winners rounds only)
│   ├── Divider
│   ├── Text("LOSER'S BRACKET")
│   ├── BracketView (losers rounds only)
│   ├── Divider
│   ├── Text("GRAND FINALS")
│   └── GrandFinalsView (special layout)
```

### Layout Calculator Changes

```dart
class DoubleBracketLayoutCalculator {
  final List<List<Match>> winnersRoundMatches;
  final List<List<Match>> losersRoundMatches;
  final List<Match> grandFinalsMatches;

  // Winner's bracket: standard layout
  // Loser's bracket: positioned below with connecting lines to winner's
  // Grand finals: centered at the end
}
```

### Visual Design

```
┌─────────────────────────────────────────────────────────┐
│  WINNER'S BRACKET                                       │
│  ┌────┐     ┌────┐     ┌────┐                          │
│  │ M1 │──┐  │    │     │    │                          │
│  └────┘  ├──│ M5 │──┐  │    │                          │
│  ┌────┐  │  │    │  │  │    │      ┌──────────────┐    │
│  │ M2 │──┘  └────┘  ├──│ WF │──────│              │    │
│  └────┘             │  │    │      │    GRAND     │    │
│  ┌────┐     ┌────┐  │  └────┘  ┌───│    FINALS    │    │
│  │ M3 │──┐  │    │──┘          │   │              │    │
│  └────┘  ├──│ M6 │             │   └──────────────┘    │
│  ┌────┐  │  │    │             │                       │
│  │ M4 │──┘  └────┘             │                       │
│  └────┘       │                │                       │
│               ▼ (losers)       │                       │
├─────────────────────────────────────────────────────────┤
│  LOSER'S BRACKET                                       │
│  ┌────┐     ┌────┐     ┌────┐     ┌────┐              │
│  │ L1 │──┐  │    │     │    │     │    │              │
│  └────┘  ├──│ L3 │──┐  │    │     │    │              │
│  ┌────┐  │  │    │  ├──│ L5 │──┐  │    │──────────────┘
│  │ L2 │──┘  └────┘  │  │    │  ├──│ LF │
│  └────┘     ▲       │  └────┘  │  │    │
│             │       │          │  └────┘
│     (from W-R2)     │  (from W-Finals)
└─────────────────────────────────────────────────────────┘
```

### Color Coding
- **Winner's Bracket**: Primary orange tint
- **Loser's Bracket**: Secondary teal tint
- **Grand Finals**: Gold/winner color
- **Eliminated path**: Muted/gray

---

## UI Changes

### Tournament Setup Screen

Add third tournament type button:

```dart
Row(
  children: [
    _TypeButton(label: 'KNOCKOUT', ...),
    _TypeButton(label: 'DOUBLE ELIM', icon: Icons.repeat, ...),  // NEW
    _TypeButton(label: 'ROUND ROBIN', ...),
  ],
)
```

With description tooltip: "Lose twice to be eliminated"

### Tournament Dashboard

- Show bracket type indicator (Winners/Losers/Grand Finals) in round headers
- Color-code rounds by bracket type
- Show "DROP TO LOSERS" indicator when a car loses in winner's bracket

### Bracket Screen

- Detect double elimination tournament
- Use `DoubleBracketView` instead of `BracketView`
- Add legend explaining the two brackets

---

## Implementation Phases

### Phase 1: Data Model Updates (Schema Changes)
1. Add `BracketType` enum
2. Update `TournamentType` enum with `doubleElimination`
3. Add `bracketType` field to Round model
4. Add `matchPosition` and `loserGoesTo` to Match model
5. Run `flutter pub run build_runner build` to regenerate Isar schemas
6. **Note**: This requires database migration or fresh install

### Phase 2: Tournament Service - Bracket Generation
1. Implement `_createDoubleEliminationBrackets()`
2. Create winner's bracket rounds (reuse existing knockout logic)
3. Create loser's bracket round structure
4. Pre-create empty matches with `loserGoesTo` links
5. Write unit tests for bracket generation

### Phase 3: Tournament Service - Match Progression
1. Implement `_handleDoubleEliminationMatchComplete()`
2. Implement `_routeLoserToLosersBracket()`
3. Implement `_advanceWinnerInBracket()`
4. Implement `_handleGrandFinalsResult()` (with optional bracket reset)
5. Update `getTournamentWinner()` for double elimination
6. Write unit tests for match progression

### Phase 4: Tournament Setup UI
1. Add "DOUBLE ELIM" button to setup screen
2. Add info tooltip explaining double elimination
3. Minimum 4 cars required (vs 2 for knockout)

### Phase 5: Bracket View - Double Elimination
1. Create `DoubleBracketView` widget
2. Create `DoubleBracketLayoutCalculator`
3. Add section headers (Winner's/Loser's/Grand Finals)
4. Draw cross-bracket connections (loser drops)
5. Add bracket type color coding

### Phase 6: Dashboard Updates
1. Update round headers to show bracket type
2. Add color coding for bracket types
3. Show "DROPPED TO LOSERS" status for eliminated-from-winners cars

### Phase 7: Testing & Polish
1. Test with various tournament sizes (4, 5, 6, 7, 8, 16 cars)
2. Test edge cases (byes in both brackets)
3. Test bracket reset scenario
4. Performance testing with large brackets

---

## Complexity Assessment

| Component | Complexity | Risk |
|-----------|------------|------|
| Data model changes | Medium | Low (additive) |
| Bracket generation | High | Medium |
| Match progression | High | High (complex routing) |
| Loser routing | High | High |
| Grand finals logic | Medium | Medium |
| UI setup | Low | Low |
| Bracket view | High | Medium |
| Dashboard updates | Medium | Low |

**Total Estimate**: Significant feature (~800-1200 lines of code)

---

## Design Decisions (Confirmed)

1. **Bracket Reset**: NO - Single grand final match (simpler for kids)
2. **Minimum Players**: 4 cars minimum required for double elimination
3. **Bye Handling**: Auto-advance with bye indicator (same as single elimination)
4. **Visual Priority**: Matches can be played in parallel

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Database schema change breaks existing data | Add migration or detect & skip for old tournaments |
| Complex loser routing bugs | Extensive unit tests, visual bracket validation |
| Bracket view becomes cluttered | Collapsible sections, zoom controls |
| Kid confusion with two brackets | Clear labels, color coding, simple explanations |
| Performance with large brackets | Lazy loading, virtualization if needed |

---

## Acceptance Criteria

- [ ] Can create double elimination tournament from setup screen
- [ ] Winner's bracket works like single elimination
- [ ] Losers drop to loser's bracket at correct positions
- [ ] Loser's bracket eliminates on second loss
- [ ] Grand finals determines tournament winner
- [ ] Bracket view shows both brackets clearly
- [ ] Dashboard shows bracket type for each round
- [ ] Works with 4, 8, and 16 player tournaments
- [ ] Handles byes correctly in both brackets
- [ ] Existing knockout/round robin tournaments still work
