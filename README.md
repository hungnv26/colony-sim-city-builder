# Unnamed Colony Sim City Builder Game

A 2D top-down colony simulation and city builder game inspired by Rimworld, Dwarf Fortress, SimCity 2000, and Cities: Skylines. Features abstracted unit graphics with deep, interconnected systems that model real-world social and economic mechanics. Built with Godot 4.5.1 using procedurally-generated SVG graphics.

## Project Status

**Current Phase**: Phase 5 (In Progress - Resource Gathering System)
**Completed**: Phase 1 ✅ | Phase 2 ✅ | Phase 3 ✅ | Phase 4 ✅ | Phase 5.1 ✅
**Development**: 12 phases planned (see [ROADMAP.md](ROADMAP.md))

## Quick Start

1. **Open Project** - Launch Godot 4.5.1 and open `project.godot`
2. **Generate Sprites** - Run `scripts/tools/generate_sprites.gd` (File > Run)
3. **Play** - Press F5, click "New Game"

**Controls**:
- **Camera**: WASD/Arrow keys (pan), Middle mouse drag (pan), Mouse wheel (zoom), Screen edges (edge scroll)
- **Selection**: Left click on colonist to select and view stats
- **Building**: Press B to open build menu, select building, click to place, ESC to cancel
- **Harvesting**: Right click on trees/rocks/ore to designate for harvest

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

**Phase 3 - Basic Colonist System**
- **Colonist Entities** - Health, hunger, energy, mood stats with real-time decay
- **Survival Mechanics** - Hunger (0.5/sec decay), Energy (0.3/sec decay when active)
- **Death System** - Starvation, exhaustion, and injury-based death
- **Selection System** - Click-to-select with info panel display
- **Mood System** - Dynamic calculation based on needs
- **Colonist Manager** - Spawns and manages 3 starting colonists
- **AI Task System** - Priority-based task queue with autonomous behavior
- **A* Pathfinding** - 8-directional navigation with walkability checks
- **Autonomous Behaviors**:
  - Idle wandering (5-second intervals, 100-unit radius)
  - Auto food gathering (searches 20-tile radius for trees)
  - Auto sleep (when energy < 30%)
- **Task Priority System** - CRITICAL (sleep) > HIGH (food) > NORMAL > LOW > IDLE
- **Real-time Task Display** - UI shows current task and colonist state

**Phase 4 - Building System (Complete)**
- **Building Data System** - 6 categories (Storage, Housing, Production, Utility, Defense, Decoration)
- **8 Building Types** - Storage Shed, Warehouse, Sleeping Quarters, House, Workbench, Kitchen, Campfire, Wall
- **Building Manager** - Placement preview, validation, resource consumption
- **Construction System** - Time-based construction with progress tracking
- **Auto-Assignment** - Colonists automatically assigned to construction tasks
- **Build Menu UI** - Categorized building selection with B key toggle
- **Resource Requirements** - Buildings consume wood/stone from player inventory

**Phase 5 - Resource Gathering (Harvesting Complete)**
- **Harvest Task System** - Colonists can harvest trees, rocks, iron ore, and gold ore
- **Resource Yields** - Trees give 20 wood, rocks give 15 stone, iron ore gives 10 metal, gold ore gives 5 gold
- **Harvest Times** - Trees (3s), Rocks (5s), Iron ore (8s), Gold ore (10s)
- **Designation System** - Right-click resources to designate for harvesting
- **Visual Indicators** - Yellow pulsing markers show designated harvest locations
- **Auto-Assignment** - Available colonists automatically assigned to harvest jobs
- **Job Management** - Tracks active jobs, reassigns if colonist becomes unavailable

### Project Structure
```
scenes/
  ├── menu/main_menu.tscn           # Entry point
  ├── gameplay/game_world.tscn      # Layered world (Terrain/Buildings/Units/Effects)
  └── ui/game_ui.tscn               # HUD overlay
scripts/
  ├── autoload/                     # GameStateManager, InputManager, ResourceManager
  ├── systems/                      # Game systems and SVG generators
  │   ├── building_manager.gd       # Building placement & management
  │   ├── building_data.gd          # Building data structure
  │   └── building_definitions.gd   # Building type registry
  ├── entities/                     # Colonist & Building entities
  ├── ai/                           # Task system and pathfinding
  │   ├── task.gd                   # Base task class
  │   ├── task_queue.gd             # Priority queue manager
  │   ├── pathfinding.gd            # A* implementation
  │   └── tasks/                    # Specific task implementations
  │       ├── idle_task.gd          # Wandering behavior
  │       ├── move_to_task.gd       # Pathfinding movement
  │       ├── find_food_task.gd     # Food gathering
  │       ├── sleep_task.gd         # Rest behavior
  │       └── construct_building_task.gd  # Building construction
  ├── ui/                           # UI controllers
  │   ├── build_menu.gd             # Building selection UI
  │   └── colonist_info_panel.gd    # Colonist stats display
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
- **Colonist Simulation**: 3 autonomous colonists with hunger, energy, and mood systems
- **Selection & UI**: Click colonists to view real-time stats and current task
- **Camera System**: Full pan, zoom, and edge scroll controls
- **Death Mechanics**: Colonists die from starvation (~200 sec) or exhaustion if no food available
- **AI Behaviors**: Colonists autonomously wander, search for food, sleep when tired, construct buildings, and harvest resources
- **Pathfinding**: A* navigation around terrain obstacles
- **Resource Consumption**: Trees disappear when used as food or harvested
- **Building System**: Place buildings from categorized menu (B key), colonists auto-assigned to construct
- **Resource Economy**: Buildings require wood/stone, consumed from player inventory on placement
- **Construction Progress**: Buildings show visual construction progress and completion
- **Harvesting System**: Right-click resources to designate for harvest, colonists automatically gather materials
- **Resource Gathering**: Harvest trees for wood, rocks for stone, ore for metal/gold - all added to player inventory
- **Visual Feedback**: Yellow pulsing indicators show designated harvest locations

### Coming Next (Phase 5 & Beyond)
- Resource hauling and storage buildings
- Crafting and production systems
- Zone designations (stockpile, growing, etc.)
- Advanced job system with skill levels
- Proper food production (farming)
- Crafting system

## Development

See [ROADMAP.md](ROADMAP.md) for the complete 12-phase development plan covering all planned features from foundation to release.

### Key Files
- `scripts/autoload/` - GameStateManager, InputManager, ResourceManager
- `scripts/systems/game_world.gd` - World initialization and systems integration
- `scripts/systems/terrain_generator.gd` - Procedural world generation
- `scripts/systems/world_tilemap.gd` - Chunk-based tilemap rendering
- `scripts/entities/colonist.gd` - Colonist entity with AI integration
- `scripts/systems/colonist_manager.gd` - Colonist lifecycle management
- `scripts/ai/pathfinding.gd` - A* pathfinding algorithm
- `scripts/ai/task_queue.gd` - Priority-based task management
- `scripts/ai/tasks/` - Task implementations (idle, move, find_food, sleep)
- `scripts/tools/generate_sprites.gd` - Batch sprite generation

## Notes

- Generated SVG sprites require Godot to reimport (may need editor restart)
- Minimap, Load Game, and Settings are placeholders
- Starting resources: 50 wood, 50 stone, 20 food
- Starting colonists: 3 (spawn at world center)
- World generation seed: -1 (random) or set specific seed for reproducible terrain
- **Colonists are fully autonomous** - they will wander, find food, and sleep on their own
- Food source: Trees (temporary - proper food system coming in Phase 4)
- Phase toggles available in GameWorld scene: `enable_phase2_terrain`, `enable_phase3_colonists`
