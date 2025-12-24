# Project Name: Derby Dash (Local-First Hot Wheels App) - v2

## 1. Role & Objective
**Role:** You are a Senior Flutter Engineer.
**Objective:** Build a local-first, offline-capable mobile app for managing physical Hot Wheels car tournaments.
**Key Design Philosophy:** "Kid-First." UI must be high-contrast, large-touch, and resilient to random tapping.

---

## 2. Technical Stack & Architecture
* **Framework:** Flutter (Dart).
* **Database:** **Isar** (Strict requirement for relational queries and static typing).
* **State Management:** **Riverpod** (AsyncNotifier/Code Generation).
* **Image Handling:** `image_picker` + `image_cropper` (Force 1:1 Square Crop).
* **Backend:** **NONE.** Local-only architecture.
* **Navigation:** GoRouter (or standard Navigator 2.0).

---

## 3. Data Schema (Isar Optimized)

### A. Car
* `id`: Id (Isar auto-increment).
* `uuid`: String (Unique identifier).
* `name`: String.
* `photoPath`: String (Local filesystem path).
* `isDeleted`: Boolean (Default: `false`). **Critical:** Use "Soft Delete." Do not remove records from DB; just filter them out of the "Garage" UI.
* **Note:** Do *not* store aggregate stats (wins/losses) as integers. These must be calculated dynamically to ensure data integrity.

### B. Tournament
* `id`: Id.
* `date`: DateTime.
* `status`: Enum (`setup`, `active`, `completed`).
* `type`: Enum (`knockout`, `roundRobin`). **Note:** "Swiss" mode is cut from MVP Scope.
* `rounds`: Link to `Round` objects (One-to-Many).

### C. Round
* `id`: Id.
* `roundNumber`: Int (1, 2, 3...).
* `isCompleted`: Boolean.
* `matches`: Link to `Match` objects.

### D. Match
* `id`: Id.
* `carA`: Link to `Car`.
* `carB`: Link to `Car` (Nullable if it's a "Bye").
* `winner`: Link to `Car` (Nullable).
* `isBye`: Boolean (True if a car advances automatically).

---

## 4. Feature Specifications

### Phase 1: The Garage (Car Management)
* **Grid UI:** Show only `Car` objects where `isDeleted == false`.
* **Add Car Flow:**
    1.  Camera opens immediately.
    2.  **Constraint:** Force a **1:1 Square Crop** editor after the photo is taken.
    3.  Enter Name -> Save.
* **Deletion:** If a user deletes a car, set `isDeleted = true`. Do not purge history.

### Phase 2: Tournament Setup (MVP Scoped)
* **Selection:** User selects cars. Show count (e.g., "4/8").
* **Modes:**
    1.  **Knockout:** Standard single-elimination bracket.
    2.  **Round Robin:** Every car races every other car once.
* **Sorting:** Randomize the "seed" order upon tournament creation.

### Phase 3: The Race Logic (The "Brain")
* **Match Screen:**
    * Split screen: Car A vs Car B.
    * Tap Winner -> Winner Animates -> Updates DB -> Auto-navigates to "Tournament Dashboard" after 2 seconds.
* **"Bye" Handling (Odd Numbers):**
    * If a match is a "Bye" (`isBye == true`), show a special screen: *"Blue Shark gets a free pass!"*
    * Interaction: Child must tap a "Next" button to acknowledge. Do not auto-skip.
* **Undo Logic:**
    * Place a small "Undo" button on the active match screen *after* a winner is tapped but before navigation occurs.
    * Action: Resets the local state of the *current* match (clears `winner` field) to allow re-selection. It does not navigate back to previous matches.

### Phase 4: App Lifecycle & Stats
* **Resume State:** If the app is killed and restarted, open to the **Tournament Dashboard**, not the specific active match. This prevents state confusion.
* **Dynamic Stats:**
    * To show "Total Wins" in the Garage, write a service that queries Isar: `matches.filter().winner.id(carId).count()`.

---

## 5. Implementation Sequence for AI Agent

**Step 1: Database Foundation**
* Set up Isar. Create the Schema exactly as defined above.
* Generate the `g.dart` files.

**Step 2: Car Management**
* Implement `ImagePicker` with `ImageCropper` (Square).
* Build the Garage Grid (Filter by `!isDeleted`).

**Step 3: Tournament Engine (Logic First)**
* Write `TournamentService` class.
* Implement `createKnockoutBracket(List<Car>)`.
    * *Logic:* Shuffle list. Take chunks of 2. If 1 remains, mark as Bye. Create `Round` 1.
* Implement `completeMatch(Match match, Car winner)`.
    * *Logic:* Update Match. Check if Round is complete. If yes, generate pairings for Next Round.

**Step 4: UI Construction**
* Build the "VS" Screen.
* Build the "Bye" Screen.
* Build the "Tournament Dashboard" (List of active matches).

---

## 6. Constraints Checklist
* [ ] Does the app work if I put the phone in Airplane mode? **(YES)**
* [ ] Are the buttons large enough for a 6-year-old? **(YES)**
* [ ] Does the app crash if I have an odd number of cars? **(NO - Handled by Bye logic)**
* [ ] Are photos square? **(YES - enforced at capture)**
