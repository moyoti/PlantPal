import WidgetKit
import SwiftUI
import UIKit

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
        completion(loadEntry() ?? placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantPalWidgetEntry>) -> Void) {
        let entry = loadEntry() ?? placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
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

struct SpriteImageView: View {
    let evolutionLevel: Int
    let mood: String
    let size: CGFloat

    var body: some View {
        let imageName = "sprite_\(evolutionLevel)_\(mood)_1"
        let image = loadIcon(named: imageName)
        if let uiImage = image {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.none)
                .frame(width: size, height: size)
        } else {
            Text(fallbackEmoji)
                .font(.system(size: size * 0.7))
                .frame(width: size, height: size)
        }
    }

    private var fallbackEmoji: String {
        switch mood {
        case "excited": return "✨"
        case "happy": return "🧚"
        case "worried": return "😟"
        case "sad": return "😢"
        case "sleeping": return "💤"
        default: return "🧚"
        }
    }
}

struct InteractionIconView: View {
    let iconName: String
    let deepLink: String
    let color: Color
    let label: String

    var body: some View {
        Link(destination: URL(string: deepLink)!) {
            VStack(spacing: 2) {
                if let uiImage = loadIcon(named: iconName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 24, height: 24)
                } else {
                    Text(label).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                }
            }
            .frame(width: 36, height: 36)
            .background(color)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.15), lineWidth: 1))
        }
    }
}

struct WidgetStatBar: View {
    let iconName: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            if let uiImage = loadIcon(named: iconName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 12, height: 12)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * min(1, max(0, value))), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

private func loadIcon(named: String) -> UIImage? {
    if let img = UIImage(named: named) { return img }
    let parentURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
    guard let parentBundle = Bundle(url: parentURL) else { return nil }
    guard let url = parentBundle.url(forResource: named, withExtension: "png") else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }
    return UIImage(data: data)
}

struct SmallWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        VStack(spacing: 4) {
            SpriteImageView(evolutionLevel: entry.spriteEvolutionLevel, mood: entry.spriteMood, size: 52)

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

            HStack(spacing: 4) {
                InteractionIconView(iconName: "icon_water", deepLink: "plantpal://water", color: Color(red: 0.26, green: 0.65, blue: 0.96), label: "💧")
                InteractionIconView(iconName: "icon_light", deepLink: "plantpal://light", color: Color(red: 1, green: 0.84, blue: 0.31), label: "☀️")
                InteractionIconView(iconName: "icon_touch", deepLink: "plantpal://touch", color: Color(red: 0.93, green: 0.25, blue: 0.48), label: "👆")
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
}

struct MediumWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                SpriteImageView(evolutionLevel: entry.spriteEvolutionLevel, mood: entry.spriteMood, size: 64)

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

                WidgetStatBar(iconName: "icon_water", value: entry.waterLevel, color: Color(red: 0.26, green: 0.65, blue: 0.96))
                WidgetStatBar(iconName: "icon_light", value: entry.lightLevel, color: Color(red: 1, green: 0.84, blue: 0.31))
                WidgetStatBar(iconName: "icon_fertilize", value: entry.health, color: Color(red: 0.3, green: 0.69, blue: 0.31))
                WidgetStatBar(iconName: "icon_pet", value: entry.spriteHappiness, color: Color(red: 0.93, green: 0.25, blue: 0.48))

                Text("💰 \(entry.coinCount)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(red: 1, green: 0.84, blue: 0))

                HStack(spacing: 6) {
                    InteractionIconView(iconName: "icon_water", deepLink: "plantpal://water", color: Color(red: 0.26, green: 0.65, blue: 0.96), label: "水")
                    InteractionIconView(iconName: "icon_light", deepLink: "plantpal://light", color: Color(red: 1, green: 0.84, blue: 0.31), label: "光")
                    InteractionIconView(iconName: "icon_touch", deepLink: "plantpal://touch", color: Color(red: 0.93, green: 0.25, blue: 0.48), label: "触")
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
}

@available(iOS 16.0, *)
struct LockScreenWidgetView: View {
    let entry: PlantPalWidgetEntry

    var body: some View {
        HStack(spacing: 6) {
            SpriteImageView(evolutionLevel: entry.spriteEvolutionLevel, mood: entry.spriteMood, size: 20)
            Text(entry.plantName).font(.caption2)
            if entry.needsAttention { Text("⚠️") }
            if !entry.needsAttention { Text("❤️\(Int(entry.spriteHappiness * 100))%").font(.system(size: 9)) }
        }
    }
}

@main
struct PlantPalWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlantPalSmallWidget()
        PlantPalMediumWidget()
        PlantPalLockScreenWidget()
    }
}

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
