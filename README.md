# Unnamed Colony Sim City Builder Game

A 2D top-down colony simulation and city builder game inspired by Rimworld, Dwarf Fortress, SimCity 2000, and Cities: Skylines. Features abstracted unit graphics with deep, interconnected systems that model real-world social and economic mechanics. Built with Godot 4.5.1 using procedurally-generated SVG graphics.

## Project Status

**Current Phase**: Phase 3 (In Progress - Core Systems Complete)
**Completed**: Phase 1 ✅ | Phase 2 ✅ | Phase 3 Part 1 ✅
**Development**: 12 phases planned (see [ROADMAP.md](ROADMAP.md))

## Quick Start

1. **Open Project** - Launch Godot 4.5.1 and open `project.godot`
2. **Generate Sprites** - Run `scripts/tools/generate_sprites.gd` (File > Run)
3. **Play** - Press F5, click "New Game"

**Controls**:
- **Camera**: WASD/Arrow keys (pan), Middle mouse drag (pan), Mouse wheel (zoom), Screen edges (edge scroll)
- **Selection**: Left click on colonist to select and view stats

## Architecture

### Core Systems Implemented

**Phase 1 - Foundation**
- **Game State Machine** - Menu, Playing, Paused, Game Over states
- **Input Manager** - Signal-based input handling with selection support
- **Resource Manager** - Tracks wood, stone, food, metal, gold
- **Camera System** - Pan, zoom, edge scrolling with smooth interpolation
- **SVG Graphics Pipeline** - Procedural sprite generation

**Phase 2 - World & Terrain**
- **Procedural Terrain** - 100x100 tile world with FastNoiseLite generation
- **6 Terrain Types** - Grass, Dirt, Stone, Water, Sand, Snow (elevation + moisture-based)
- **Chunk-Based Rendering** - 16x16 tile chunks for performance optimization
- **Natural Resources** - Trees, rocks, iron ore, gold ore with procedural placement
- **Tilemap System** - 32px tiles with sprite variations

**Phase 3 - Colonist System (Part 1)**
- **Colonist Entities** - Health, hunger, energy, mood stats with real-time decay
- **Survival Mechanics** - Hunger (0.5/sec decay), Energy (0.3/sec decay when active)
- **Death System** - Starvation, exhaustion, and injury-based death
- **Selection System** - Click-to-select with info panel display
- **Mood System** - Dynamic calculation based on needs
- **Colonist Manager** - Spawns and manages 3 starting colonists

### Project Structure
```
scenes/
  ├── menu/main_menu.tscn           # Entry point
  ├── gameplay/game_world.tscn      # Layered world (Terrain/Buildings/Units/Effects)
  └── ui/game_ui.tscn               # HUD overlay
scripts/
  ├── autoload/                     # GameStateManager, InputManager, ResourceManager
  ├── systems/                      # Game systems and SVG generators
  ├── ui/                           # UI controllers
  └── tools/                        # Sprite generation utilities
assets/sprites/                     # Generated SVG sprites
```

### SVG Sprite Generators
- **Colonists** - 4 body types, 6 skin tones, randomized colors (10 variations)
- **Buildings** - Storage, Sleeping Quarters, Workbench, Wall, House
- **Terrain** - Grass, Dirt, Stone, Water, Sand, Snow (3 variations each)
- **Resources** - Tree, Rock, Iron Ore, Gold Ore

## Technical Details

- **Engine**: Godot 4.5.1 (Forward Plus)
- **Language**: GDScript with type hints
- **Graphics**: Procedural SVG (scalable, code-generated)
- **Architecture**: Signal-driven, decoupled systems
- **Target**: 60 FPS

## Features

### Currently Working
- **World System**: 100x100 procedurally generated terrain with 6 biomes
- **Resource Deposits**: Trees, rocks, iron/gold ore scattered across the map
- **Colonist Simulation**: 3 living colonists with hunger, energy, and mood systems
- **Selection & UI**: Click colonists to view real-time stats (health, hunger, energy, mood)
- **Camera System**: Full pan, zoom, and edge scroll controls
- **Death Mechanics**: Colonists die from starvation (~200 sec) or exhaustion

### Coming Next (Phase 3 Part 2 & Beyond)
- Task queue system for colonist AI
- Autonomous behaviors (idle wander, find food, sleep)
- Task priority system
- A* pathfinding for navigation
- Animation states

## Development

See [ROADMAP.md](ROADMAP.md) for the complete 12-phase development plan covering all planned features from foundation to release.

### Key Files
- `scripts/autoload/` - GameStateManager, InputManager, ResourceManager
- `scripts/systems/game_world.gd` - World initialization and systems integration
- `scripts/systems/terrain_generator.gd` - Procedural world generation
- `scripts/systems/world_tilemap.gd` - Chunk-based tilemap rendering
- `scripts/entities/colonist.gd` - Colonist entity with stat systems
- `scripts/systems/colonist_manager.gd` - Colonist lifecycle management
- `scripts/tools/generate_sprites.gd` - Batch sprite generation

## Notes

- Generated SVG sprites require Godot to reimport (may need editor restart)
- Minimap, Load Game, and Settings are placeholders
- Starting resources: 50 wood, 50 stone, 20 food
- Starting colonists: 3 (spawn at world center)
- World generation seed: -1 (random) or set specific seed for reproducible terrain
- Colonists currently have no AI - they will stand idle and eventually die without manual intervention
- Phase toggles available in GameWorld scene: `enable_phase2_terrain`, `enable_phase3_colonists`