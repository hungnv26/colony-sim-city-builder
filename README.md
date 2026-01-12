# Unnamed Colony Sim City Builder Game

A 2D top-down colony simulation and city builder game inspired by Rimworld, Dwarf Fortress, SimCity 2000, and Cities: Skylines. Features abstracted unit graphics with deep, interconnected systems that model real-world social and economic mechanics. Built with Godot 4.5.1 using procedurally-generated SVG graphics.

## Project Status

**Current Phase**: Phase 1 Complete ✅
**Development**: 12 phases planned (see [ROADMAP.md](ROADMAP.md))

## Quick Start

1. **Open Project** - Launch Godot 4.5.1 and open `project.godot`
2. **Generate Sprites** - Run `scripts/tools/generate_sprites.gd` (File > Run)
3. **Play** - Press F5, click "New Game"

**Controls**: WASD/Arrow keys (pan), Middle mouse drag (pan), Mouse wheel (zoom), Screen edges (edge scroll)

## Architecture

### Core Systems Implemented (Phase 1)
- **Game State Machine** - Menu, Playing, Paused, Game Over states
- **Input Manager** - Signal-based input handling
- **Resource Manager** - Tracks wood, stone, food, metal, gold
- **Camera System** - Pan, zoom, edge scrolling with smooth interpolation
- **SVG Graphics Pipeline** - Procedural sprite generation

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
- **Colonists** - 4 body types, 6 skin tones, randomized colors
- **Buildings** - Storage, Sleeping Quarters, Workbench, Wall, House
- **Terrain** - Grass, Dirt, Stone, Water, Sand, Snow (3 variations each)

## Technical Details

- **Engine**: Godot 4.5.1 (Forward Plus)
- **Language**: GDScript with type hints
- **Graphics**: Procedural SVG (scalable, code-generated)
- **Architecture**: Signal-driven, decoupled systems
- **Target**: 60 FPS

## Features

### Currently Working
- Main menu with scene transitions
- Camera controls (WASD, middle mouse drag, mouse wheel zoom, edge scroll)
- Resource tracking system
- Game state management
- SVG sprite generation

### Coming Next (Phase 2)
- Tile-based world generation
- Resource deposits (trees, rocks, ore)
- A* pathfinding
- Terrain rendering

## Development

See [ROADMAP.md](ROADMAP.md) for the complete 12-phase development plan covering all planned features from foundation to release.

### Key Files
- `scripts/autoload/game_state_manager.gd` - State machine
- `scripts/systems/game_camera.gd` - Camera controller
- `scripts/tools/generate_sprites.gd` - Batch sprite generation

## Notes

- Generated SVG sprites require Godot to reimport (may need editor restart)
- Minimap, Load Game, and Settings are placeholders
- Starting resources: 50 wood, 50 stone, 20 food