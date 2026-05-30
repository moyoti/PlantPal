import WidgetKit
import SwiftUI
import SwiftData

struct PlantPalWidgetEntry: TimelineEntry {
    let date: Date
    let plantName: String
    let health: Double
    let waterLevel: Double
    let lightLevel: Double
    let spriteMood: String
    let spriteEvolutionLevel: Int
    let spriteHappiness: Double
    let needsAttention: Bool
    let coinCount: Int
}

struct PlantPalWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlantPalWidgetEntry {
        PlantPalWidgetEntry(
            date: Date(), plantName: "小绿", health: 0.85,
            waterLevel: 0.6, lightLevel: 0.7, spriteMood: "happy",
            spriteEvolutionLevel: 4, spriteHappiness: 0.8,
            needsAttention: false, coinCount: 150
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantPalWidgetEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            completion(loadEntry() ?? placeholder(in: context))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantPalWidgetEntry>) -> Void) {
        let entry = loadEntry() ?? placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> PlantPalWidgetEntry? {
        let defaults = UserDefaults(suiteName: "group.com.plantpal.app")
        return PlantPalWidgetEntry(
            date: Date(),
            plantName: defaults?.string(forKey: "plantName") ?? "小绿",
            health: defaults?.double(forKey: "health") ?? 0.85,
            waterLevel: defaults?.double(forKey: "waterLevel") ?? 0.6,
            lightLevel: defaults?.double(forKey: "lightLevel") ?? 0.7,
            spriteMood: defaults?.string(forKey: "spriteMood") ?? "happy",
            spriteEvolutionLevel: defaults?.integer(forKey: "spriteEvolutionLevel") ?? 4,
            spriteHappiness: defaults?.double(forKey: "spriteHappiness") ?? 0.8,
            needsAttention: defaults?.bool(forKey: "needsAttention") ?? false,
            coinCount: defaults?.integer(forKey: "coins") ?? 0
        )
    }
}

// MARK: - Small Widget
struct PlantPalSmallWidget: Widget {
    let kind: String = "PlantPalWidgetSmall"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [Color(red: 0.91, green: 0.96, blue: 0.91), Color(red: 1, green: 0.97, blue: 0.82)], startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("精灵状态")
        .description("查看精灵心情和植物状态")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
            VStack(spacing: 4) {
                Text(spriteEmoji)
                    .font(.system(size: 36))

                Text(entry.plantName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.2))

            if entry.needsAttention {
                Text("⚠️ 需要照顾")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.red)
            } else {
                Text(moodText)
                    .font(.system(size: 8))
                    .foregroundColor(Color(red: 0.3, green: 0.69, blue: 0.31))
            }

            HStack(spacing: 6) {
                Link(destination: URL(string: "plantpal://water")!) {
                    Text("💧").font(.system(size: 14))
                }
                Link(destination: URL(string: "plantpal://light")!) {
                    Text("☀️").font(.system(size: 14))
                }
                Link(destination: URL(string: "plantpal://touch")!) {
                    Text("👆").font(.system(size: 14))
                }
            }
            .padding(.top, 2)
        }
    }

    private var moodText: String {
        switch entry.spriteMood {
        case "excited": return "超开心 ✨"
        case "happy": return "开心 😊"
        case "worried": return "担心 🥺"
        case "sad": return "难过 😢"
        case "sleeping": return "睡觉 💤"
        default: return "还好"
        }
    }

    private var spriteEmoji: String {
        switch entry.spriteMood {
        case "excited": return "✨"
        case "happy": return "🧚"
        case "worried": return "😟"
        case "sad": return "😢"
        case "sleeping": return "💤"
        default: return "🧚"
        }
    }
}

// MARK: - Medium Widget
struct PlantPalMediumWidget: Widget {
    let kind: String = "PlantPalWidgetMedium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [Color(red: 0.91, green: 0.96, blue: 0.91), Color(red: 1, green: 0.97, blue: 0.82)], startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("花园状态")
        .description("查看植物状态和快速互动")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(spriteEmoji)
                    .font(.system(size: 44))

                Text(moodText)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.2))

                if entry.needsAttention {
                    Text("⚠️ 需要照顾")
                        .font(.system(size: 8))
                        .foregroundColor(.red)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(entry.plantName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.18, blue: 0.18))

                WidgetStatBar(icon: "💧", label: "水", value: entry.waterLevel, color: Color(red: 0.26, green: 0.65, blue: 0.96))
                WidgetStatBar(icon: "☀️", label: "光", value: entry.lightLevel, color: Color(red: 1, green: 0.84, blue: 0.31))
                WidgetStatBar(icon: "❤️", label: "命", value: entry.health, color: Color(red: 0.3, green: 0.69, blue: 0.31))
                WidgetStatBar(icon: "😊", label: "心", value: entry.spriteHappiness, color: Color(red: 0.93, green: 0.25, blue: 0.48))

                Text("💰 \(entry.coinCount)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(red: 1, green: 0.84, blue: 0))

                HStack(spacing: 8) {
                    Link(destination: URL(string: "plantpal://water")!) {
                        Text("💧浇水").font(.system(size: 9, weight: .semibold)).foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color(red: 0.26, green: 0.65, blue: 0.96))
                            .cornerRadius(4)
                    }
                    Link(destination: URL(string: "plantpal://light")!) {
                        Text("☀️光照").font(.system(size: 9, weight: .semibold)).foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color(red: 1, green: 0.84, blue: 0.31))
                            .cornerRadius(4)
                    }
                    Link(destination: URL(string: "plantpal://touch")!) {
                        Text("👆互动").font(.system(size: 9, weight: .semibold)).foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color(red: 0.93, green: 0.25, blue: 0.48))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 2)
            }
        }
    }

    private var moodText: String {
        switch entry.spriteMood {
        case "excited": return "超开心✨"
        case "happy": return "开心😊"
        case "worried": return "担心🥺"
        case "sad": return "难过😢"
        case "sleeping": return "睡觉💤"
        default: return "还好"
        }
    }

    private var spriteEmoji: String {
        switch entry.spriteMood {
        case "excited": return "✨"
        case "happy": return "🧚"
        case "worried": return "😟"
        case "sad": return "😢"
        case "sleeping": return "💤"
        default: return "🧚"
        }
    }
}

struct WidgetStatBar: View {
    let icon: String
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(icon).font(.system(size: 8))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * value), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Lock Screen Widget
struct PlantPalLockScreenWidget: Widget {
    let kind: String = "PlantPalLockScreen"

    var body: some WidgetConfiguration {
        if #available(iOS 16.0, *) {
            return StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { entry in
                LockScreenWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color(red: 0.91, green: 0.96, blue: 0.91)
                    }
            }
            .configurationDisplayName("植物精灵")
            .description("锁屏显示精灵状态")
            .supportedFamilies([.accessoryRectangular])
        } else {
            return StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { _ in EmptyView() }
        }
    }
}

@available(iOS 16.0, *)
struct LockScreenWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 6) {
            Text(moodEmoji)
            Text(entry.plantName).font(.caption2)
            if entry.needsAttention { Text("⚠️") }
            if !entry.needsAttention { Text("❤️\(Int(entry.spriteHappiness * 100))%").font(.system(size: 9)) }
        }
    }

    private var moodEmoji: String {
        switch entry.spriteMood {
        case "excited": return "✨"
        case "happy": return "😊"
        case "worried": return "🥺"
        case "sad": return "😢"
        case "sleeping": return "💤"
        default: return "🌱"
        }
    }
}

// MARK: - Widget Bundle
@main
struct PlantPalWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlantPalSmallWidget()
        PlantPalMediumWidget()
        PlantPalLockScreenWidget()
    }
}
