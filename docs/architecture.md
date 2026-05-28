# PlantPal — Architecture & Data Model Specification

## 1. App Concept

**PlantPal** is a pure-client mobile app (iOS + Android) featuring pixel-art style plant nurturing with a guardian sprite companion. No server required — all data stored locally.

### Core Mechanics

| Mechanic | Description |
|----------|-------------|
| **Time Passage** | Plant needs periodic watering/light; neglect → wilt warning, sprite alerts |
| **Habit Tasks** | Real-life tasks (drink 8 cups water, exercise, wake early) → earn nutrients/sunlight |
| **Direct Interaction** | Touch sprite → happy animation; water → droplet FX; fertilize → growth boost |
| **Growth & Evolution** | Seed → sprout → bloom → fruit lifecycle; sprite evolves with plant |

---

## 2. Project Structure

```
AIGenPrj/
├── docs/                    # Shared architecture docs (this file)
├── ios/                     # iOS project (Xcode)
│   └── PlantPal/
│   │   ├── App/             # App entry, SwiftUI views
│   │   ├── Models/          # SwiftData models
│   │   ├── Services/        # Time engine, notification, habit tracker
│   │   ├── Views/           # Main screen, interaction, habit list, settings
│   │   ├── Resources/       # Pixel art sprites, animations
│   │   └── Widgets/         # WidgetKit extension
│   └── PlantPalWidget/      # Widget extension target
├── android/                 # Android project (Gradle)
│   └── app/
│   │   ├── src/main/
│   │   │   ├── java/com/plantpal/
│   │   │   │   ├── data/        # Room DB, repositories
│   │   │   │   ├── ui/          # Compose screens
│   │   │   │   ├── engine/      # Time engine, growth calculator
│   │   │   │   ├── widget/      # GlanceAppWidget
│   │   │   │   ├── model/       # Domain entities
│   │   │   │   └── navigation/  # NavHost
│   │   │   └── res/             # Pixel art resources
│   │   └── src/debug/           # Debug variant
│   │   └ build.gradle.kts
│   └── build.gradle.kts        # Root
└── shared/                  # Shared design tokens (JSON)
    ├── sprites/             # Pixel art source files
    └── design-tokens.json   # Colors, typography, spacing
```

---

## 3. Core Data Models (Shared Logic)

### 3.1 Plant

```swift
// iOS (SwiftData)
@Model
class Plant {
    var id: UUID
    var name: String
    var species: PlantSpecies       // enum: succulent, flower, tree, herb
    var growthStage: GrowthStage    // enum: seed, sprout, bud, bloom, fruit, wilted
    var health: Double              // 0.0 - 1.0 (wilt threshold: 0.3)
    var growthProgress: Double      // 0.0 - 1.0 per stage (reaches 1.0 → evolve)
    var waterLevel: Double          // 0.0 - 1.0 (decays over time)
    var lightLevel: Double          // 0.0 - 1.0 (decays over time)
    var nutrients: Double           // 0.0 - 100.0 (accumulated from habits)
    var lastWateredAt: Date
    var lastLightAt: Date
    var plantedAt: Date
    var totalDaysAlive: Int
    var potStyle: String            // decorative pot identifier
    var backgroundScene: String     // background scene identifier
}
```

```kotlin
// Android (Room Entity)
@Entity(tableName = "plants")
data class PlantEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String,
    val species: String,            // "succulent", "flower", "tree", "herb"
    val growthStage: String,        // "seed", "sprout", "bud", "bloom", "fruit", "wilted"
    val health: Double = 1.0,       // 0.0 - 1.0
    val growthProgress: Double = 0.0, // 0.0 - 1.0 per stage
    val waterLevel: Double = 1.0,   // 0.0 - 1.0
    val lightLevel: Double = 1.0,   // 0.0 - 1.0
    val nutrients: Double = 0.0,    // 0.0 - 100.0
    val lastWateredAt: Long,        // epoch millis
    val lastLightAt: Long,
    val plantedAt: Long,
    val totalDaysAlive: Int = 0,
    val potStyle: String = "default",
    val backgroundScene: String = "garden"
)
```

### 3.2 Sprite (Guardian)

```swift
// iOS
@Model
class Sprite {
    var id: UUID
    var name: String
    var mood: SpriteMood            // enum: happy, sad, worried, excited, sleeping
    var evolutionLevel: Int          // 1-5 (evolves with plant stage)
    var happiness: Double            // 0.0 - 1.0
    var outfit: String               // outfit identifier
    var lastInteractedAt: Date
    var interactionCount: Int
}
```

```kotlin
// Android
@Entity(tableName = "sprites")
data class SpriteEntity(
    @PrimaryKey val id: String,
    val name: String,
    val mood: String,               // "happy", "sad", "worried", "excited", "sleeping"
    val evolutionLevel: Int = 1,    // 1-5
    val happiness: Double = 0.5,    // 0.0 - 1.0
    val outfit: String = "default",
    val lastInteractedAt: Long,
    val interactionCount: Int = 0
)
```

### 3.3 HabitTask

```swift
// iOS
@Model
class HabitTask {
    var id: UUID
    var title: String
    var icon: String                 // SF Symbol name (iOS) / emoji fallback
    var frequency: TaskFrequency     // enum: daily, weekly, custom
    var nutrientReward: Double       // nutrients earned on completion
    var sunlightReward: Double       // sunlight earned on completion
    var isCompletedToday: Bool
    var streakCount: Int
    var createdAt: Date
}
```

```kotlin
// Android
@Entity(tableName = "habit_tasks")
data class HabitTaskEntity(
    @PrimaryKey val id: String,
    val title: String,
    val iconEmoji: String,          // emoji for icon
    val frequency: String,          // "daily", "weekly", "custom"
    val nutrientReward: Double,
    val sunlightReward: Double,
    val isCompletedToday: Boolean = false,
    val streakCount: Int = 0,
    val createdAt: Long
)
```

### 3.4 InteractionRecord

```swift
// iOS
@Model
class InteractionRecord {
    var id: UUID
    var type: InteractionType        // enum: water, light, fertilize, touch, talk
    var plantId: UUID
    var timestamp: Date
    var effectValue: Double          // how much was restored/added
}
```

```kotlin
// Android
@Entity(tableName = "interactions")
data class InteractionEntity(
    @PrimaryKey val id: String,
    val type: String,               // "water", "light", "fertilize", "touch", "talk"
    val plantId: String,
    val timestamp: Long,
    val effectValue: Double
)
```

---

## 4. Enums & Constants

### PlantSpecies
```
succulent  — Low water need, slow growth, hardy
flower     — Medium water, medium growth, colorful blooms
tree       — High water need, slow growth, long lifecycle
herb       — Medium water, fast growth, fragrant
```

### GrowthStage
```
seed     → sprout:   growthProgress ≥ 1.0, water & light > 0.3
sprout   → bud:      growthProgress ≥ 1.0, water & light > 0.4
bud      → bloom:    growthProgress ≥ 1.0, water & light > 0.5
bloom    → fruit:    growthProgress ≥ 1.0, water & light > 0.6, nutrients ≥ 30
fruit    → (final stage, plant "reborn" as new seed after celebration)
wilted   → recovery: water & light restored above 0.3, health recovers
```

### SpriteMood (derived from plant state)
```
happy     — plant health > 0.7, water/light > 0.5
excited   — plant just evolved or task completed
worried   — plant health < 0.5 or water/light < 0.3
sad       — plant health < 0.3 (wilted)
sleeping  — night time (22:00-07:00 local)
```

### Sprite Evolution Levels
```
Level 1 — Seed sprite: tiny, floating orb with eyes (matches seed stage)
Level 2 — Sprout sprite: small leaf-winged fairy (matches sprout stage)
Level 3 — Bud sprite: winged fairy with flower hat (matches bud stage)
Level 4 — Bloom sprite: full fairy with petal dress (matches bloom stage)
Level 5 — Fruit sprite: radiant fairy with crown (matches fruit stage)
```

### InteractionType & Effects
```
water     → waterLevel += 0.3 (cooldown: 2 hours), droplet animation
light     → lightLevel += 0.3 (cooldown: 2 hours), sparkle animation
fertilize → nutrients += 5.0 (costs nutrients from habit bank), glow animation
touch     → sprite happiness += 0.1, sprite blush animation
talk      → sprite happiness += 0.05, sprite dialogue bubble
```

---

## 5. Time Engine Logic (Shared Algorithm)

### Decay Rates (per hour, species-dependent)

```
Succulent:  water −0.02/hr,  light −0.03/hr,  health −0.01/hr (below thresholds)
Flower:     water −0.04/hr,  light −0.04/hr,  health −0.02/hr
Tree:       water −0.05/hr,  light −0.03/hr,  health −0.02/hr
Herb:       water −0.03/hr,  light −0.05/hr,  health −0.02/hr

Health decay triggers when: water < 0.3 OR light < 0.3
Wilt threshold: health < 0.3 → growthStage = wilted
```

### Growth Rate (per hour)
```
growthProgress += (waterLevel × lightLevel × health × baseGrowthRate)
where baseGrowthRate:
  Succulent: 0.005/hr
  Flower:    0.010/hr
  Tree:      0.003/hr
  Herb:      0.015/hr

Nutrient bonus: growthProgress × (1 + nutrients/200)  (nutrients act as multiplier)
```

### Calculation Method
```
On app open / foreground:
1. Calculate elapsedHours = (now - lastCalculationTime) / 3600
2. Apply decay: waterLevel -= decayRate × elapsedHours (clamp 0-1)
3. Apply decay: lightLevel -= decayRate × elapsedHours (clamp 0-1)
4. If water < 0.3 OR light < 0.3: health -= healthDecay × elapsedHours
5. If water > 0.3 AND light > 0.3 AND health > 0.3: health += 0.01 × elapsedHours (slow recovery)
6. If NOT wilted: growthProgress += growthFormula × elapsedHours
7. If growthProgress ≥ 1.0 AND thresholds met: evolveToNextStage()
8. Update lastCalculationTime = now
```

---

## 6. UI Architecture

### iOS (SwiftUI)

```
App
├── MainTabView
│   ├── GardenTab (primary)
│   │   └── GardenView
│   │       ├── PlantSceneView (sprite + plant canvas)
│   │       ├── InteractionPanel (water/light/fertilize/touch buttons)
│   │       └── StatusBarView (health/water/light bars)
│   ├── HabitsTab
│   │   └── HabitListView
│   │       ├── HabitCardView (per task)
│   │       └── AddHabitSheet
│   ├── CollectionTab
│   │   ├── EvolutionGalleryView (past plants)
│   │   └── DecorationStoreView (pots, backgrounds, outfits)
│   └── SettingsTab
│       └── SettingsView (notifications, theme, reset)
```

### Android (Compose + Navigation)

```
App
├── NavHost
│   ├── GardenScreen (primary)
│   │   ├── PlantSceneComposable (sprite + plant canvas)
│   │   ├── InteractionPanel (water/light/fertilize/touch buttons)
│   │   ├── StatusBarComposable (health/water/light bars)
│   ├── HabitsScreen
│   │   ├── HabitCardComposable (per task)
│   │   ├── AddHabitDialog
│   ├── CollectionScreen
│   │   ├── EvolutionGallery
│   │   ├── DecorationStore
│   ├── SettingsScreen
```

---

## 7. Widget Data Contract

### Shared minimal state for widget rendering

```json
{
  "plantName": "小绿",
  "growthStage": "bloom",
  "health": 0.85,
  "waterLevel": 0.6,
  "lightLevel": 0.7,
  "spriteMood": "happy",
  "spriteEvolutionLevel": 4,
  "needsAttention": false,
  "lastUpdated": 1700000000000
}
```

### iOS Widget (WidgetKit)
- Home Screen: medium rectangle widget showing plant + sprite + status bars
- Lock Screen: small rectangular widget showing sprite face + attention indicator

### Android Widget (GlanceAppWidget)
- 4×2 widget: plant sprite pixel art + name + status bars + "needs attention" badge

---

## 8. Design Tokens (Shared)

```json
{
  "colors": {
    "primary": "#4CAF50",
    "primaryDark": "#2E7D32",
    "accent": "#FF9800",
    "background": "#F5F5DC",
    "surface": "#FFFFFF",
    "danger": "#F44336",
    "warning": "#FFEB3B",
    "water": "#42A5F5",
    "sunlight": "#FFD54F",
    "health": "#66BB6A",
    "nutrients": "#8D6E63"
  },
  "typography": {
    "pixelFont": "PressStart2P",
    "bodyFont": "Nunito"
  },
  "spacing": {
    "xs": 4,
    "sm": 8,
    "md": 16,
    "lg": 24,
    "xl": 32
  }
}
```

---

## 9. Pixel Art Sprite Specifications

### Sprite Sheet Format
- Each sprite frame: 32×32 pixels (scaled 4x to 128×128 for display)
- Animation: 4-8 frames per action
- File format: PNG with transparency

### Required Sprite Sets

| Sprite Set | Frames | Description |
|-----------|--------|-------------|
| **seed_idle** | 4 | Tiny orb floating, blinking |
| **seed_happy** | 4 | Orb bouncing excitedly |
| **sprout_idle** | 6 | Small fairy hovering, leaf wings flutter |
| **sprout_happy** | 6 | Fairy spinning with joy |
| **bud_idle** | 6 | Fairy with flower hat, gentle sway |
| **bud_worried** | 6 | Fairy looking at plant, frowning |
| **bloom_idle** | 8 | Full fairy, petal dress, graceful hover |
| **bloom_excited** | 8 | Fairy celebrating with sparkles |
| **fruit_idle** | 8 | Radiant fairy with crown, royal pose |
| **sleeping** | 4 | All levels: curled up, Zzz bubbles |

### Plant Sprite Sets

| Plant Stage | Frames | Description |
|-------------|--------|-------------|
| **seed** | 4 | Small seed in soil, slight shimmer |
| **sprout** | 6 | Tiny stem with 2 leaves, gentle sway |
| **bud** | 8 | Stem with bud forming, occasional pulse |
| **bloom** | 8 | Full flower open, petals moving |
| **fruit** | 8 | Flower with fruit, occasional glow |
| **wilted** | 6 | Drooping leaves, gray tint |

### Interaction Effects

| Effect | Frames | Description |
|--------|--------|-------------|
| **water_drops** | 8 | Blue droplets falling onto plant |
| **light_sparkles** | 8 | Yellow sparkles radiating |
| **fertilize_glow** | 8 | Brown/green glow rising from soil |
| **touch_bubbles** | 6 | Hearts/stars floating from sprite |
| **evolve_flash** | 8 | White flash + particles |

---

## 10. Notification Strategy

### iOS (UNUserNotificationCenter)
- Water reminder: when waterLevel < 0.3 (check every 4 hours)
- Light reminder: when lightLevel < 0.3 (check at sunrise)
- Habit reminder: configurable time per task (default: 09:00)
- Evolution celebration: immediate when plant evolves

### Android (AlarmManager + WorkManager)
- Periodic check: every 4 hours via WorkManager
- Water/light alerts: NotificationChannel "Plant Care"
- Habit reminders: AlarmManager for precise time
- Evolution: immediate notification