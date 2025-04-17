# gwj_80 (Working Title)

## Overview

**gwj_80** is a grid-based card color puzzle game built with the Godot Engine for the web (HTML5). Players use cards featuring different shapes and colors to paint a 16x9 grid. The goal is to replicate a target image as accurately as possible within a limited number of turns.

## Gameplay

* **Grid:** 16x9 cells, initially white.
* **Cards:** Players manage a hand of cards. Each card has:
  * **Shape:** Determines the pattern of cells affected:
    * `O`: Hollow 3x3 square (8 cells).
    * `PLUS (+)`: Center cell plus 4 cardinal neighbors (5 cells).
    * `XLine (-)`: Horizontal 3-cell line (3 cells).
    * `YLine (|)`: Vertical 3-cell line (3 cells).
    * `XShape (X)`: Center cell plus 4 diagonal neighbors (5 cells).
  * **Color:** Red (R), Green (G), or Blue (B).
* **Turns:** The game proceeds in turns, with a limit of 15 turns per round (as per GDD).
* **Actions:**
    1. Select a card from your hand.
    2. Click a cell on the grid to apply the card's shape and color, centered on the clicked cell.
    3. Colors blend with the existing cell color. (Note: Applying a 5th color/blend turns the cell black - specific blending logic TBD).
    4. Draw a new card automatically.
* **Objective:** Match the final grid state to a target image provided at the start of the round.
* **Scoring:** Your score is based on the percentage match between your grid and the target grid.

## Current Status

Development is currently focused on building the core **sandbox mode**, allowing players to freely experiment with placing cards and coloring the grid. Target image replication and scoring mechanics will be implemented next.

## How to Play (Controls)

* **Select Card:** Click on a card in your hand.
* **Place Card:** Click on a cell in the main grid.

## Technical Details

* **Engine:** Godot Engine 4.x
* **Platform:** Web (HTML5 Export)
* **Art Style:** Pixel Art
* **Theme:** Retro Psychedelic
