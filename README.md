# CaveDiver

CaveDiver is an underwater diving game developed with Godot 4. The game features mechanics such as an inventory system, a game manager for player stats, various mobile enemies (mobs), and a dynamic HUD. This repository contains all source code, assets, and scenes needed to run and test the game.


---

## 📁 Key Directories & Roles

### Mob/
- Enemy-related scenes and hitbox/hurtbox definitions:
    - `Mob.tscn` (main enemy template)
    - `Hitbox.tscn` and `Hurtbox.tscn`
    - `MobDead.gdshader.uid` (shader reference for dead mobs)

### Scripts/
Organized into subfolders by system.

#### HUD/
- `HUD.gd` — Updates UI elements like oxygen, weight, and BCD inflation in sync with player stats.

#### Inventory/
Implements a robust **inventory system** with items, equipment, and management:
- `Enums.gd` — Shared enumerations.
- `Item.gd`, `Equipment.gd` — Object definitions.
- `Inventory.gd` — 2D grid inventory logic.
- `EquipmentRegistry.gd`, `ItemRegistry.gd` — Factories for creating equipment/items.
- `InventoryManager.gd` — Tracks equipped and stored gear.
- `InventoryTest.gd` — Unit tests for inventory behaviors.

#### Map/
**Level/world systems**:
- `Map.gd` — Placeholder for world logic.
- `RopeAnchor.gd`, `RopeSegment.gd` — **Rope climbing system** allowing dynamic rope placement and interaction.
- `silt.gd` — Silt particle effects when objects enter specific areas.

#### Mob/
- `Mob.gd` — Complete **enemy AI**, including:
    - Navigation/pathfinding.
    - Awareness/aggression/fear.
    - Impulse-based movement.
    - Death handling and shading.

#### Player/
- `Player.gd` — The **diver’s control script**, handling:
    - Movement, sprinting, buoyancy.
    - Speargun shooting.
    - Rope anchoring.
    - Oxygen/bubble mechanics.
- `PlayerBubble.gd` — Floating bubble behavior.
- `spear.gd` — Spear projectile movement and collision.

#### Systems/
- `GameManager.gd` — Tracks health, oxygen, BCD inflation, and emits relevant signals.
- `SaveSystem.gd` — Save/load for basic player stats.
- `SoundManager.gd` — Placeholder for audio management.

---

## 🎨 Shaders/

- `Map.gdshader` — Dynamic visibility and underwater effects relative to player position and look direction.
- `Mob.gdshader` — Mob-specific visibility and fading effects.
- `ShaderContext.gd` — Passes player and mouse position to shaders in real time for accurate visual feedback.

---

## 🏗 Things/

**Scene instances for in-game objects**:
- `player_bubble.tscn`
- `projectile_bubbles.tscn`
- `rope_anchor.tscn`
- `rope_segment.tscn`
- `silt.tscn`
- `spear.tscn`

---

## 🌊 Scenes

- `main_scene.tscn` — The primary scene, likely containing the player, map, and root nodes.
- `Player.tscn` — Player’s scene file with all required nodes and scripts attached.

---

