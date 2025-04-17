# Game Technical Document: gwj_80

## 1. Technical Architecture

### 1.1 Engine and Tools

- **Game Engine:** Godot Engine (Version 4.x - specific version TBD, likely latest stable)
- **Version Control:** Git
- **IDE/Editor:** VS Code (with Godot Tools extension recommended)
- **Art Tools:** [Specify tools for pixel art creation, e.g., Aseprite, Piskel]
- **Audio Tools:** [Specify tools for sound/music creation, e.g., Audacity, Bosca Ceoil]

### 1.2 Programming Languages

- **Primary:** GDScript

### 1.3 Libraries and APIs

- **Internal:** Godot Engine API
- **Addons:**
  - Maaack's Game Template (Provides base menus, scene loading, settings management - see `cline_brain/techContext.md`)
- **External:** None planned currently.

## 2. Implementation Details

### 2.1 Core Systems

- **Grid System:** Manages the 16x9 grid state, cell colors, and blending logic.
- **Card System:** Handles card data (shape, color), player hand management, drawing cards.
- **Input System:** Processes player input for card selection and grid placement.
- **Color Blending Logic:** Implements the rules for combining RGB colors (up to 5 blends -> black).
- **Target Image/Level System:** Loads target grid images for puzzles.
- **Scoring System:** Calculates the percentage match between the player grid and the target grid.
- **Turn Management:** Tracks the 15-turn limit per round.
- **UI System:** Manages display of grid, hand, target, score, turns, menus (leveraging Maaack's template where possible).
- **Sandbox Mode:** Initial implementation focus - allows free placement of cards without targets or scoring.

### 2.2 Data Structures

- **Grid Data:** Likely a 2D Array or Dictionary representing the 16x9 grid, storing cell color (e.g., Color object) and blend count.
- **Card Data:** Custom Resource (`CardData.tres`?) storing shape (enum/string) and color (Color object).
- **Player Hand:** Array storing current `CardData` resources.
- **Target Grid Data:** Likely a 2D Array or Image resource representing the target colors.
- **Level Data:** Custom Resource (`LevelData.tres`?) storing the target grid data, potentially turn limit overrides, etc.

### 2.3 Algorithms

- **Color Blending:** Define the specific algorithm for blending RGB colors (e.g., additive, averaging?). Needs careful definition.
- **Shape Application:** Logic to determine which grid cells are affected based on card shape and placement position.
- **Scoring Calculation:** Algorithm to compare player grid cells to target grid cells and calculate percentage match.
- **Level Generation (from image):** Potential future algorithm to analyze a larger pixel art image, break it into 16x9 chunks, and reverse-engineer possible card sequences (complex, for level design tool?).

## 3. Task-Based Schedule (Initial High-Level)

*(Focus on Sandbox First)*

- **[x] Task 1:** Project Setup (Confirm Godot version, Git repo, basic structure).
- **[x] Task 2:** Implement Grid System (Data structure, basic display).
- **[x] Task 3:** Implement Card Data Structure (Resource definition).
- **[x] Task 4:** Implement Card Shapes Logic (Applying shapes to grid coordinates).
- **[x] Task 5:** Implement Basic Color Application (Overwrite/Initial Blend).
- **[x] Task 6:** Implement Player Hand UI (Displaying cards).
- **[x] Task 7:** Implement Card Drawing Logic (Basic draw per turn).
- **[x] Task 8:** Implement Input Handling (Selecting card, clicking grid).
- **[x] Task 9:** Integrate Card Placement (Connecting input, card selection, shape logic, color application).
- **[X] Task 10:** Refine Color Blending Logic (Implement 5-blend rule -> black).
- **[X] Task 11:** Build Basic Sandbox UI (Grid, Hand).
- --- *Sandbox Complete ---*
- **[ ] Task 12:** Implement Target Image Loading/Display.
- **[ ] Task 13:** Implement Turn Limit System.
- **[ ] Task 14:** Implement Scoring System (% match calculation).
- **[ ] Task 15:** Implement End-of-Round UI (Show results).
- **[ ] Task 16:** Create Initial Target Levels.
- **[ ] Task 17:** Integrate with Menu System (Maaack's template).

## 4. Coding Standards and Conventions

- Follow official GDScript Style Guide (see `cline_brain/gdscript_guidelines.md`).
- Use static typing extensively.
- Document code clearly (classes, methods, complex logic).
- Follow naming conventions outlined in guidelines.
- Keep functions small and focused.

## 5. Testing and Quality Assurance

- **Manual Testing:** Frequent testing of the sandbox mode during initial development.
- **Unit Testing (Optional):** Consider GUT for testing core logic like color blending, scoring calculation if complex.
- **Playtesting:** Test puzzle difficulty and clarity once target levels are implemented.
- **Bug Tracking:** Use GitHub Issues (or similar).

## 6. Build Process and Deployment

- **Target Platform:** Web (HTML5).
- **Build Automation:** Utilize GitHub Actions workflow (`.github/workflows/github_to_itch.yml`) for automated builds and deployment to Itch.io.
- **Export Settings:** Configure HTML5 export preset in Godot.

## 7. Performance Optimization

- **Initial Focus:** Clean, functional code.
- **Later Stages:** Profile if performance issues arise (unlikely for this scope on Web, but possible with complex blending/many cells).
- **Considerations:** Efficient grid data access, optimize color blending calculations if needed.

## 8. Version Control

- **System:** Git.
- **Workflow:** Feature branches for significant changes, frequent commits to `main` (or `develop` branch if preferred). Use descriptive commit messages.
- **Repository:** [Link to GitHub repository if available].

## 9. Risk Management

- **Risk 1:** Color blending logic becomes overly complex or visually unintuitive. **Mitigation:** Define blending clearly early on, test visually in sandbox.
- **Risk 2:** Level design (reverse-engineering cards from images) is too difficult/time-consuming. **Mitigation:** Focus on sandbox first. Simplify level requirements if needed, or build a basic level editor tool.
- **Risk 3:** Balancing puzzle difficulty is hard. **Mitigation:** Extensive playtesting, start with simpler target images.
- **Risk 4:** Scope creep (adding too many shapes, colors, mechanics). **Mitigation:** Stick to the defined core mechanics for the jam. Revisit scope after initial version.

---
*This document is a living document and will be updated throughout development.*
