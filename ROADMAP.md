# Colony Sim City Builder - Development Roadmap

## Project Vision

A 2D top-down colony simulation and city builder game inspired by Rimworld, Dwarf Fortress, SimCity 2000, and Cities: Skylines. The game will feature abstracted unit graphics with deep, interconnected systems that model real-world social and economic mechanics. Built with Godot 4.5.1 using SVG-based procedural graphics.

---

## Phase 1: Foundation & Core Architecture ✅ COMPLETE

### 1.1 Project Structure Setup
- [x] Create main scene hierarchy (Menu, Gameplay, UI layers)
- [x] Establish folder structure (scenes/, scripts/, assets/, resources/)
- [x] Set up autoload singletons for core managers
- [x] Implement basic game state machine (Menu, Playing, Paused)
- [x] Create input handling system

### 1.2 SVG Graphics Pipeline
- [x] Build SVG sprite generation system
- [x] Create procedural unit/colonist sprite generator
- [x] Develop basic building sprite templates
- [x] Implement terrain tile SVG generation
- [x] Set up sprite caching and optimization

### 1.3 Camera & Viewport
- [x] Implement 2D camera with pan and zoom
- [x] Add camera edge scrolling and keyboard controls
- [x] Create viewport bounds and minimap placeholder
- [x] Implement smooth camera transitions

**Implementation Notes:**
- Created 13 GDScript files and 3 scenes
- Autoloads: GameStateManager, InputManager, ResourceManager
- SVG generators for colonists (4 body types), buildings (5 types), terrain (6 types)
- Camera controls: WASD/arrows, middle mouse drag, mouse wheel zoom (0.5-3.0x), edge scrolling
- Instant response for middle mouse drag, smooth interpolation for keyboard
- Signal-based architecture for decoupled systems
- Organized folder structure ready for expansion

---

## Phase 2: World & Terrain System (Weeks 4-6) ✅ COMPLETE

### 2.1 Tile-Based World ✅
- [x] Design tile data structure (terrain type, elevation, resources)
- [x] Implement tilemap rendering system
- [x] Create procedural terrain generation (noise-based)
- [x] Add terrain types (grass, dirt, stone, water, sand, snow)
- [x] Implement chunk loading for large maps

**Implementation Notes:**
- GameTileData class with terrain/resource enums, elevation, walkability
- Chunk-based rendering (16x16 tiles, 32px size) with WorldTilemap
- FastNoiseLite: Perlin noise for elevation, Simplex for moisture
- 6 terrain types determined by elevation + moisture thresholds
- 3 visual variations per terrain type for variety

### 2.2 Resource Deposits ✅
- [x] Place natural resource nodes (trees, rocks, ore deposits)
- [x] Create resource visualization (SVG icons/overlays)
- [x] Implement resource quantity tracking
- [ ] Add resource regeneration mechanics (trees regrow) - DEFERRED

**Implementation Notes:**
- Procedural placement using cellular noise
- Trees (30% on grass), Rocks (20% on stone/dirt), Ore (10% on stone)
- Resource sprites rendered as overlays (z_index = 1)
- Quantity ranges: Trees 50-100, Rocks 30-60, Ore 20-50
- 80% iron ore, 20% gold ore distribution

### 2.3 Pathfinding Foundation ✅ (Completed in Phase 3.3)
- [x] Implement A* pathfinding algorithm
- [x] Create navigation grid from tilemap
- [x] Add walkability rules (water blocks, buildings block)
- [ ] Optimize pathfinding with spatial partitioning - DEFERRED

**Implementation Notes:**
- A* algorithm with 8-directional movement in pathfinding.gd
- Manhattan heuristic for distance estimation
- Walkability checks from tile data (water blocks movement)
- Path simplification removes unnecessary waypoints
- Node tree traversal to locate game world from nested colonist nodes

---

## Phase 3: Basic Colonist System (Weeks 7-9) - COMPLETE ✅

### 3.1 Colonist Entity ✅
- [x] Create colonist entity class with stats (health, hunger, energy, mood)
- [x] Implement colonist sprite rendering (SVG-based)
- [ ] Add basic animation states (idle, walking, working) - DEFERRED
- [x] Create colonist selection and info panel UI

**Implementation Notes:**
- CharacterBody2D with full stat system (health, hunger, energy, mood)
- Stat decay: hunger 0.5/sec, energy 0.3/sec when active
- Energy recovery: 2.0/sec when sleeping
- State machine: IDLE, WALKING, WORKING, SLEEPING, EATING, DEAD
- Click-to-select with real-time stat display in UI panel
- UI shows current task description with 0.5s refresh rate

### 3.2 Needs & Survival ✅
- [x] Implement hunger system with food consumption
- [x] Add rest/sleep requirement with energy tracking
- [x] Create basic mood/happiness system
- [x] Implement death conditions (starvation, exhaustion, injuries)

**Implementation Notes:**
- Hunger and energy deplete continuously, mood calculated from both
- Death triggers at 0 hunger (starvation), 0 energy (exhaustion), or 0 health
- Colonist manager spawns 3 starting colonists at world center
- Selection indicator (yellow highlight) shows on selected colonist

### 3.3 Basic AI & Tasks ✅
- [x] Build task queue system
- [x] Implement A* pathfinding algorithm
- [x] Implement idle behavior (wander, rest)
- [x] Create "Find Food" autonomous task
- [x] Add "Sleep" task with bed-seeking behavior
- [x] Design task priority system

**Implementation Notes:**
- Task base class with 5 priority levels (IDLE=0, LOW=1, NORMAL=2, HIGH=3, CRITICAL=4)
- TaskQueue manages priority-sorted tasks with single-task execution
- A* pathfinding with 8-directional movement, walkability checks, path simplification
- Autonomous behaviors: Idle wander (5s intervals, 100-unit radius), Find food (20-tile search radius), Sleep (when energy < 30%)
- Task implementations: Task, MoveToTask, IdleTask, FindFoodTask, SleepTask
- Colonists autonomously navigate using pathfinding, gather food from trees (removes resource), and rest
- Node tree traversal (_find_game_world helper) to locate game world from nested colonist nodes
- Food gathering restores 40 hunger points, sleep continues until energy reaches 95%
- Tasks check can_execute() before running (prevents dead colonists from executing tasks)

---

## Phase 4: Construction & Building System (Weeks 10-13)

### 4.1 Building Framework ✅
- [x] Create building definition data structure
- [x] Implement building placement preview system
- [x] Add placement validation (terrain, collision, proximity)
- [x] Build construction task and colonist construction jobs
- [x] Create building health and durability system

**Implementation Notes:**
- BuildingData class with 6 categories (Storage, Housing, Production, Utility, Defense, Decoration)
- 8 building types defined: Storage Shed, Warehouse, Sleeping Quarters, House, Workbench, Kitchen, Campfire, Wall
- BuildingManager handles placement preview (green/red overlay), validation, and resource consumption
- ConstructBuildingTask with 3 stages: MOVING_TO_SITE, CONSTRUCTING, COMPLETE
- Construction progress calculated as delta/build_time, visual opacity increases during construction
- Buildings track health, construction progress, grid position, and occupied tiles
- Automatic colonist assignment when building placed (finds idle colonist or least-busy worker)
- Resource validation checks ResourceManager inventory before placement
- Building entities with visual components (sprite, construction overlay, health bar)

### 4.2 Basic Structures ✅
- [x] Storage building (stores resources) - Storage Shed (2x2, 500 capacity), Warehouse (4x4, 2000 capacity)
- [x] Sleeping quarters (beds for colonists) - Sleeping Quarters (3x2), House (3x3)
- [x] Food storage (preserves food items) - Included in storage buildings
- [x] Work benches (crafting stations) - Workbench (2x1), Kitchen (3x2)
- [x] Walls and basic defenses - Wall (1x1, 200 health), Campfire (1x1 utility)

**Implementation Notes:**
- Buildings have resource requirements (wood/stone), build time, size, terrain restrictions
- Storage buildings have storage_capacity property for future inventory systems
- Production buildings have work_speed_bonus multiplier
- Walls have high health (200) and basic blocking functionality
- Each building has color-coded placeholder sprite and sprite_path for future SVG assets

### 4.3 Construction UI ✅
- [x] Design build menu with categorized buildings
- [x] Implement building rotation controls (deferred - not needed for 1x1 and symmetric buildings)
- [x] Add construction material requirements display
- [x] Create building info tooltips

**Implementation Notes:**
- Build menu UI with TabContainer for 6 building categories
- Each building button shows: name, size, build time, resource costs
- Toggle with B key or "Build (B)" button in top bar
- ESC key cancels placement mode
- Build menu positioned on left side, stays open for multiple placements
- Mouse hover updates placement preview position in real-time
- Green overlay when valid placement, red when invalid (terrain/collision check)
- Resource costs displayed in format: "Cost: 20 Wood, 10 Stone"

---

## Phase 5: Resource Gathering & Production (Weeks 14-17)

### 5.1 Harvesting System
- [ ] Implement "Harvest" task (trees, rocks, plants)
- [ ] Create tool requirements (axe for trees, pickaxe for stone)
- [ ] Add resource yield calculations
- [ ] Build resource hauling task (move to storage)

### 5.2 Crafting System
- [ ] Design recipe data structure (inputs, outputs, time)
- [ ] Implement crafting workstation mechanics
- [ ] Create basic recipes (tools, furniture, food processing)
- [ ] Add crafting queue UI at workstations
- [ ] Implement skill levels affecting crafting speed/quality

### 5.3 Resource Management UI
- [ ] Build global resource counter display
- [ ] Create stockpile management interface
- [ ] Add resource filters and priority settings
- [ ] Implement low-resource warnings

---

## Phase 6: Economy & Trading Foundation (Weeks 18-20)

### 6.1 Internal Economy
- [ ] Implement item value system
- [ ] Create supply/demand tracking per resource
- [ ] Add dynamic pricing based on scarcity
- [ ] Build wealth calculation for colony

### 6.2 Trading Post
- [ ] Create trading post building
- [ ] Implement visiting trader mechanics (NPC caravans)
- [ ] Design trade UI (buy/sell interface)
- [ ] Add trade good variety and rarity tiers

### 6.3 Currency System
- [ ] Implement colony currency/credits
- [ ] Create income sources (selling goods)
- [ ] Add expenses (buying resources, upkeep costs)
- [ ] Build budget overview UI

---

## Phase 7: Social Systems (Weeks 21-24)

### 7.1 Relationships
- [ ] Implement colonist-to-colonist relationship tracking
- [ ] Create relationship modifiers (friendship, rivalry, romance)
- [ ] Add social interactions (chat, help, conflict)
- [ ] Design relationship impact on mood and productivity

### 7.2 Traits & Personalities
- [ ] Create trait system (lazy, hardworking, social, etc.)
- [ ] Implement trait effects on behavior and stats
- [ ] Add trait-based skill bonuses/penalties
- [ ] Generate random colonist personalities on spawn

### 7.3 Events & Storytelling
- [ ] Design event system framework
- [ ] Create random events (illness, accidents, visitors)
- [ ] Implement storytelling event chains
- [ ] Add event notification UI with choices

---

## Phase 8: Advanced Simulation (Weeks 25-28)

### 8.1 Job & Workforce System
- [ ] Create job role definitions (builder, farmer, crafter, etc.)
- [ ] Implement job assignment UI
- [ ] Add colonist skill progression in jobs
- [ ] Build job priority and scheduling system

### 8.2 Agriculture & Food Production
- [ ] Implement farming zones (designate crop areas)
- [ ] Create crop growth cycles (planting, growing, harvesting)
- [ ] Add seasonal effects on crops
- [ ] Build food spoilage and preservation mechanics

### 8.3 Climate & Seasons
- [ ] Implement season cycle (spring, summer, fall, winter)
- [ ] Add temperature system affecting colonists
- [ ] Create weather events (rain, snow, heat waves)
- [ ] Design seasonal resource availability changes

---

## Phase 9: Combat & Defense (Weeks 29-32)

### 9.1 Combat System
- [ ] Implement combat stats (attack, defense, accuracy)
- [ ] Create weapon and armor items
- [ ] Add health damage and healing mechanics
- [ ] Build combat AI for colonists

### 9.2 Threats & Enemies
- [ ] Design enemy factions (raiders, wildlife)
- [ ] Implement enemy spawn and attack events
- [ ] Create enemy AI (approach, attack, retreat)
- [ ] Add loot drops from defeated enemies

### 9.3 Defensive Structures
- [ ] Create walls and barriers
- [ ] Implement guard towers and turrets
- [ ] Add trap placement and activation
- [ ] Build alarm and defense coordination system

---

## Phase 10: Polish & Advanced Features (Weeks 33-36)

### 10.1 UI/UX Enhancement
- [ ] Redesign all UI panels for consistency
- [ ] Add tooltips and tutorials
- [ ] Implement keyboard shortcuts
- [ ] Create visual feedback for actions (particles, sounds)

### 10.2 Research & Technology
- [ ] Design tech tree structure
- [ ] Implement research points and accumulation
- [ ] Create unlockable buildings and recipes
- [ ] Build research UI interface

### 10.3 Save/Load System
- [ ] Implement game state serialization
- [ ] Create save file management UI
- [ ] Add autosave functionality
- [ ] Build load game menu

### 10.4 Audio & Visual Polish
- [ ] Create sound effects library
- [ ] Implement ambient music system
- [ ] Add particle effects (dust, smoke, sparks)
- [ ] Enhance lighting and visual atmosphere

---

## Phase 11: Content Expansion (Weeks 37-40)

### 11.1 Additional Buildings
- [ ] Medical facilities (hospital, clinic)
- [ ] Entertainment structures (tavern, recreation)
- [ ] Advanced production (forge, laboratory)
- [ ] Luxury and decoration buildings

### 11.2 More Colonist Depth
- [ ] Expanded needs (recreation, social, comfort)
- [ ] Mental health system (stress, breakdowns)
- [ ] Skill specialization trees
- [ ] Life stages (child, adult, elder)

### 11.3 Advanced Economy
- [ ] Implement taxation system
- [ ] Create loan and debt mechanics
- [ ] Add stock/reserve management
- [ ] Build economic forecast tools

---

## Phase 12: Optimization & Release Prep (Weeks 41-44)

### 12.1 Performance Optimization
- [ ] Profile and optimize pathfinding
- [ ] Reduce draw calls with batching
- [ ] Implement object pooling for entities
- [ ] Optimize large colony simulations (1000+ colonists)

### 12.2 Bug Fixing & Testing
- [ ] Comprehensive playtesting sessions
- [ ] Fix critical and high-priority bugs
- [ ] Balance game difficulty and progression
- [ ] Test edge cases and failure states

### 12.3 Documentation
- [ ] Write in-game tutorial system
- [ ] Create player documentation/wiki
- [ ] Document modding capabilities
- [ ] Prepare developer documentation

### 12.4 Release
- [ ] Create marketing materials (trailer, screenshots)
- [ ] Set up distribution platform (Steam, itch.io)
- [ ] Prepare launch version build
- [ ] Plan post-launch support roadmap

---

## Future Considerations (Post-Launch)

### Potential Expansions
- Multiplayer/co-op colony management
- Modding support and Steam Workshop integration
- Additional biomes (desert, arctic, jungle)
- Space/sci-fi expansion theme
- Z-level/multi-floor building system
- Advanced diplomacy with AI factions
- Vehicle and transportation systems
- More complex production chains (supply chains)

### Community Features
- Scenario editor for custom challenges
- Colony sharing and visiting
- Leaderboards and challenges
- User-generated content platform

---

## Development Principles

1. **Iterative Development**: Build systems incrementally, test frequently
2. **Emergent Gameplay**: Design systems that interact to create unexpected situations
3. **Player Agency**: Give players meaningful choices with consequences
4. **Performance First**: Optimize early for large-scale simulations
5. **Modular Design**: Keep systems decoupled for easier expansion
6. **Real-World Inspiration**: Base mechanics on realistic economic and social models
7. **Accessibility**: Ensure game is approachable despite complexity

---

## Success Metrics

- **Technical**: Stable performance with 500+ colonists and 1000+ entities
- **Gameplay**: Average play session > 3 hours
- **Content**: 50+ buildings, 100+ items, 30+ events at launch
- **Replayability**: Procedural generation creates unique scenarios
- **Community**: Active modding community within 6 months of release

---

*This roadmap is a living document and will be updated as development progresses and priorities shift.*
