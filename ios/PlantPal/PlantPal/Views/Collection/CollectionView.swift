import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [PixelPalette.greenBg, PixelPalette.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: PixelSpacing.xl) {
                    pixelHeader
                    if let plant = plants.first { currentPlantSection(plant) }
                    if let sprite = sprites.first { spriteEvolutionSection(sprite) }
                    decorationSection
                }
                .padding(PixelSpacing.lg)
                .padding(.bottom, 60)
            }
        }
    }
    
    private var pixelHeader: some View {
        VStack(spacing: PixelSpacing.xs) {
            Text("收藏").font(PixelFonts.header(size: 16)).foregroundColor(PixelPalette.darkText)
            Rectangle().fill(PixelPalette.greenPrimary).frame(height: 3).frame(width: 80)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func currentPlantSection(_ plant: Plant) -> some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "当前植物")
            HStack(spacing: PixelSpacing.md) {
                PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", size: .thumbnail)
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name).font(PixelFonts.header(size: 11)).foregroundColor(PixelPalette.darkText)
                    Text("存活 \(plant.totalDaysAlive) 天").font(PixelFonts.body(size: 12)).foregroundColor(PixelPalette.mutedText)
                    PixelBadge(text: plant.growthStage.displayName, color: PixelPalette.greenPrimary)
                }
                Spacer()
            }
            .pixelCard()
        }
    }
    
    private func spriteEvolutionSection(_ sprite: Sprite) -> some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "精灵进化")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: PixelSpacing.md) {
                    ForEach(1...5, id: \.self) { level in
                        let unlocked = level <= sprite.evolutionLevel
                        VStack(spacing: PixelSpacing.xs) {
                            ZStack {
                                PixelArtImage(name: "sprite_\(level)_idle", size: .sprite)
                                    .grayscale(unlocked ? 0 : 1)
                                    .opacity(unlocked ? 1 : 0.3)
                                if !unlocked {
                                    Image(systemName: "lock.fill").font(.system(size: 20)).foregroundColor(PixelPalette.mutedText)
                                }
                            }
                            .frame(width: 96, height: 96)
                            .overlay(
                                unlocked
                                    ? PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.greenPrimary, lineWidth: 2)
                                    : PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.cardBorder, lineWidth: 2)
                            )
                            Text(evolutionName(for: level)).font(PixelFonts.header(size: 8))
                                .foregroundColor(unlocked ? PixelPalette.darkText : PixelPalette.mutedText)
                        }
                    }
                }
                .padding(.horizontal, PixelSpacing.xs)
            }
        }
    }
    
    private var decorationSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "装饰")
            NavigationLink {
                DecorationStoreView()
            } label: {
                HStack {
                    Image(systemName: "storefront").foregroundColor(PixelPalette.greenPrimary)
                    Text("前往装饰商店").font(PixelFonts.header(size: 10)).foregroundColor(PixelPalette.darkText)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(PixelPalette.mutedText)
                }
                .pixelCard()
            }
            .buttonStyle(.plain)
        }
    }
    
    private func evolutionName(for level: Int) -> String {
        switch level {
        case 1: return "种子精灵"
        case 2: return "嫩芽仙女"
        case 3: return "花蕾精灵"
        case 4: return "花仙子"
        case 5: return "果实女王"
        default: return ""
        }
    }
}
