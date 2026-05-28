import WidgetKit
import SwiftUI
import SwiftData

struct PlantPalWidgetEntry: TimelineEntry {
    let date: Date
    let plantName: String
    let growthStage: String
    let health: Double
    let waterLevel: Double
    let lightLevel: Double
    let spriteMood: String
    let spriteEvolutionLevel: Int
    let needsAttention: Bool
}

struct PlantPalWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlantPalWidgetEntry {
        PlantPalWidgetEntry(
            date: Date(),
            plantName: "小绿",
            growthStage: "bloom",
            health: 0.85,
            waterLevel: 0.6,
            lightLevel: 0.7,
            spriteMood: "happy",
            spriteEvolutionLevel: 4,
            needsAttention: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantPalWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantPalWidgetEntry>) -> Void) {
        let entry = placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct PlantPalWidget: Widget {
    let kind: String = "PlantPalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { entry in
            PlantPalWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(red: 0.91, green: 0.96, blue: 0.91), Color(red: 1, green: 0.97, blue: 0.82)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("我的花园")
        .description("查看植物状态和精灵心情")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PlantPalWidgetEntryView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }

    private var widgetFamily: WidgetFamily {
        #if os(iOS)
        return .systemSmall
        #else
        return .systemSmall
        #endif
    }
}

struct SmallWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        VStack(spacing: 4) {
            Text(spriteEmoji)
                .font(.system(size: 32))

            Text(entry.plantName)
                .font(.caption2)
                .fontWeight(.bold)

            if entry.needsAttention {
                Text("⚠️ 需要照顾")
                    .font(.system(size: 8))
                    .foregroundColor(.red)
            } else {
                Text(moodText)
                    .font(.system(size: 8))
                    .foregroundColor(.green)
            }
        }
    }

    private var spriteEmoji: String {
        switch entry.spriteMood {
        case "happy": return "🧚"
        case "excited": return "✨"
        case "worried": return "😟"
        case "sad": return "😢"
        case "sleeping": return "💤"
        default: return "🧚"
        }
    }

    private var moodText: String {
        switch entry.spriteMood {
        case "happy": return "开心"
        case "excited": return "超开心"
        case "sleeping": return "睡觉中"
        default: return "还好"
        }
    }
}

struct MediumWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text("🌱")
                    .font(.system(size: 40))
                Text(entry.growthStage)
                    .font(.caption2)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.plantName)
                    .font(.caption)
                    .fontWeight(.bold)

                ProgressBarView(label: "水", value: entry.waterLevel, color: .blue)
                ProgressBarView(label: "光", value: entry.lightLevel, color: .yellow)
                ProgressBarView(label: "命", value: entry.health, color: .green)

                if entry.needsAttention {
                    Text("⚠️ 需要照顾")
                        .font(.system(size: 9))
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct ProgressBarView: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8))
                .frame(width: 12)
            ProgressView(value: value, total: 1.0)
                .tint(color)
        }
    }
}

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
            return StaticConfiguration(kind: kind, provider: PlantPalWidgetProvider()) { entry in
                EmptyView()
            }
        }
    }
}

@available(iOS 16.0, *)
struct LockScreenWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 6) {
            Text("🌱")
            Text(entry.plantName)
                .font(.caption2)
            if entry.needsAttention {
                Text("⚠️")
            }
        }
    }
}
