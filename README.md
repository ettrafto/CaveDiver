# CaveDiver

CaveDiver is an underwater diving game developed with Godot 4. The game features mechanics such as an inventory system, a game manager for player stats, various mobile enemies (mobs), and a dynamic HUD. This repository contains all source code, assets, and scenes needed to run and test the game.

## Features

- **Inventory System:**  
  - A grid-based inventory that supports adding, removing, and moving items.
  - Separate storage for the boat (40x20) and the player (6x4).
- **Game Management:**  
  - A GameManager for handling player stats (health, oxygen, etc.) and game state.
- **Player & Mob Systems:**  
  - A player character with movement, buoyancy, and collision.
  - Enemies (mobs) that interact with the player.
- **HUD:**  
  - Dynamic on-screen elements for oxygen, weight, and other stats.
- **Scene Setup:**  
  - Multiple scenes including the main scene and test scenes for features like the inventory system.

## File Structure
CaveDiver/
├── Mob/
│   ├── Mob.tscn
│   └── MobDead.gdshader
├── Scripts/
│   ├── HUD/
│   │   └── HUD.gd
│   ├── Inventory/
│   │   ├── Inventory.gd
│   │   ├── InventoryManager.gd
│   │   ├── InventoryTest.gd
│   │   └── Item.gd
│   ├── Map/
│   │   └── Map.gd
│   ├── Mob/
│   │   └── Mob.gd
│   ├── Player/
│   │   └── Player.gd
│   └── Systems/
│       ├── GameManager.gd
│       ├── SaveSystem.gd
│       └── SoundManager.gd
├── Scenes/
│   ├── inventory_test.tscn
│   └── main_scene.tscn
├── icon.svg
├── project.godot
└── README.md
