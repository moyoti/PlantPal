import SwiftUI
import SwiftData
import UIKit

struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    @Query private var wallets: [PlayerWallet]
    @State private var timeEngine = TimeEngine()
    @State private var activeEffect: InteractionType?
    @State private var cloudOffset: CGFloat = 0
    @State private var plantSway: CGFloat = 0
    @State private var spriteBob: CGFloat = 0
    @State private var sparklePhase: CGFloat = 0
    @State private var cooldownTimers: [InteractionType: Double] = [:]
    @State private var showInteractionMenu = false
    @State private var showStatusDetail = false
    private let cooldownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var plant: Plant? { plants.first }
    private var sprite: Sprite? { sprites.first }
    private var wallet: PlayerWallet? { wallets.first }

    private let primaryInteractions: [InteractionType] = [.water, .light, .fertilize, .touch, .pet]
    private let secondaryInteractions: [InteractionType] = [.talk, .sing, .heal, .play, .shield, .dance]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let plant, let sprite {
                    plantSceneView(plant, sprite, geo: geo)
                } else {
                    LinearGradient(
                        colors: [PixelPalette.greenBg, PixelPalette.cream],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    ProgressView("加载中...")
                        .font(PixelFonts.header(size: 10))
                }

                if let plant, let sprite {
                    topOverlay(sprite: sprite, plant: plant, wallet: wallet)
                    bottomOverlay(plant: plant, sprite: sprite)
                }
            }
        }
        .onAppear {
            ensureDefaultData()
            if let plant, let sprite {
                timeEngine.calculateTimeEffects(plant: plant, sprite: sprite, wallet: wallet)
                checkAndScheduleReminders(plant: plant)
            }
            startAmbientAnimations()
        }
        .onReceive(cooldownTimer) { _ in
            updateCooldowns()
        }
    }

    private func plantSceneView(_ plant: Plant, _ sprite: Sprite, geo: GeometryProxy) -> some View {
        ZStack {
            PixelArtImage(name: "bg_\(plant.backgroundScene)", width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()

            floatingClouds
            ambientSparkle

            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", width: min(140, geo.size.width * 0.35), height: min(200, geo.size.height * 0.35))
                        .offset(y: -geo.size.height * 0.05)
                        .rotationEffect(.degrees(Double(plantSway)), anchor: .bottom)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PixelArtImage(name: "pot_\(plant.potStyle)", width: min(110, geo.size.width * 0.28), height: min(55, geo.size.height * 0.08))
                    Spacer()
                }
            }

            AnimatedSpriteView(evolutionLevel: sprite.evolutionLevel, mood: sprite.mood, outfitName: sprite.outfit)
                .offset(x: geo.size.width * 0.18, y: -geo.size.height * 0.12 + spriteBob)

            if let effect = activeEffect {
                InteractionEffectView(type: effect)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .ignoresSafeArea()
    }

    private func topOverlay(sprite: Sprite, plant: Plant, wallet: PlayerWallet?) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(sprite.name)
                            .font(PixelFonts.header(size: 10))
                            .foregroundColor(.white)
                        PixelBadge(text: spriteMoodText(for: sprite), color: moodColor(for: sprite))
                        if plant.isSick {
                            PixelBadge(text: "生病", color: PixelPalette.redDanger)
                        }
                        if Date.now < plant.shieldedUntil {
                            PixelBadge(text: "护盾", color: PixelPalette.blueWater)
                        }
                    }
                    if sprite.fatigue > 0.5 {
                        HStack(spacing: 2) {
                            Text("疲惫")
                                .font(PixelFonts.header(size: 6))
                                .foregroundColor(PixelPalette.orangeWarn)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 24, height: 5)
                                .overlay(
                                    Rectangle().fill(PixelPalette.orangeWarn)
                                        .frame(width: 24 * min(sprite.fatigue, 1.0), height: 5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                }

                Spacer()

                if let wallet {
                    HStack(spacing: 3) {
                        Circle().fill(PixelPalette.coinGold).frame(width: 10, height: 10)
                            .overlay(Circle().stroke(PixelPalette.yellowSunDark, lineWidth: 1))
                        Text("¥\(wallet.coins)")
                            .font(PixelFonts.header(size: 8))
                            .foregroundColor(PixelPalette.coinGold)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.3))
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(PixelPalette.coinGold.opacity(0.4), lineWidth: 1))
                }

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showStatusDetail.toggle()
                    }
                } label: {
                    Image(systemName: showStatusDetail ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 6)

            if showStatusDetail {
                VStack(spacing: 4) {
                    PixelProgressBar(label: "水", value: plant.waterLevel, color: PixelPalette.blueWater)
                    PixelProgressBar(label: "光", value: plant.lightLevel, color: PixelPalette.yellowSun)
                    PixelProgressBar(label: "命", value: plant.health, color: PixelPalette.greenLight)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.25), Color.clear],
                startPoint: .top, endPoint: .bottom
            )
        )
        .frame(height: showStatusDetail ? 140 : 56)
        .clipped()
    }

    private func bottomOverlay(plant: Plant, sprite: Sprite) -> some View {
        VStack(spacing: 0) {
            Spacer()
            if showInteractionMenu {
                secondaryMenu(plant: plant, sprite: sprite)
            }
            primaryBar(plant: plant, sprite: sprite)
        }
    }

    private func secondaryMenu(plant: Plant, sprite: Sprite) -> some View {
        let rows = splitIntoRows(secondaryInteractions, columns: 3)
        return VStack(spacing: 6) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex], id: \.self) { type in
                        interactionButton(type, plant: plant, sprite: sprite)
                    }
                    if rows[rowIndex].count < 3 {
                        ForEach(0..<(3 - rows[rowIndex].count), id: \.self) { _ in
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func primaryBar(plant: Plant, sprite: Sprite) -> some View {
        HStack(spacing: 6) {
            ForEach(primaryInteractions, id: \.self) { type in
                interactionButton(type, plant: plant, sprite: sprite)
            }
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showInteractionMenu.toggle()
                }
            } label: {
                VStack(spacing: 2) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 36)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.4), lineWidth: 2))
                        Image(systemName: showInteractionMenu ? "xmark" : "ellipsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text(showInteractionMenu ? "收起" : "更多")
                        .font(PixelFonts.header(size: 6))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func interactionButton(_ type: InteractionType, plant: Plant, sprite: Sprite) -> some View {
        let remaining = cooldownTimers[type] ?? 0
        let onCooldown = remaining > 0
        let btnColor = colorForType(type)
        return Button(action: {
            guard !onCooldown else { return }
            timeEngine.applyInteraction(plant: plant, sprite: sprite, type: type, wallet: wallet)
            updateCooldowns()
            activeEffect = type
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { activeEffect = nil }
        }) {
            VStack(spacing: 2) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(btnColor.opacity(onCooldown ? 0.06 : 0.2))
                        .frame(width: 40, height: 36)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(btnColor.opacity(onCooldown ? 0.2 : 0.6), lineWidth: onCooldown ? 1 : 2))
                    PixelArtImage(name: type.icon, size: .icon)
                        .opacity(onCooldown ? 0.3 : 1.0)
                    if onCooldown {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 40, height: 36)
                            .overlay(
                                Text("\(Int(ceil(remaining)))")
                                    .font(PixelFonts.header(size: 9))
                                    .foregroundColor(.white)
                            )
                    }
                }
                Text(type.displayName)
                    .font(PixelFonts.header(size: 6))
                    .foregroundColor(onCooldown ? PixelPalette.mutedText : .white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .opacity(onCooldown ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(onCooldown)
    }

    private var floatingClouds: some View {
        VStack {
            HStack {
                cloudShape(width: 30, height: 10)
                    .offset(x: cloudOffset, y: 6)
                Spacer(minLength: 40)
                cloudShape(width: 22, height: 8)
                    .offset(x: cloudOffset * 0.7, y: 12)
                Spacer()
            }
            Spacer()
        }
        .opacity(0.25)
    }

    private func cloudShape(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width, height: height)
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width * 0.6, height: height * 0.7)
                .offset(x: -width * 0.2, y: -height * 0.3)
            RoundedRectangle(cornerRadius: 2).fill(Color.white)
                .frame(width: width * 0.5, height: height * 0.6)
                .offset(x: width * 0.2, y: -height * 0.2)
        }
    }

    private var ambientSparkle: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let phase = sparklePhase + CGFloat(i) * 1.5
                let sparkleOpacity = (sin(phase) + 1) / 2
                Rectangle()
                    .fill(PixelPalette.yellowSun.opacity(0.5))
                    .frame(width: 3, height: 3)
                    .rotationEffect(.degrees(45))
                    .offset(x: CGFloat([-20, 30, 60][i]) + sin(phase * 0.3) * 3, y: CGFloat([30, 50, 20][i]))
                    .opacity(sparkleOpacity * 0.6)
            }
        }
    }

    private func startAmbientAnimations() {
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { cloudOffset = 200 }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { plantSway = 2 }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { spriteBob = -4 }
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { sparklePhase = .pi * 2 }
    }

    private func updateCooldowns() {
        var newTimers: [InteractionType: Double] = [:]
        for type in primaryInteractions + secondaryInteractions {
            let remaining = timeEngine.cooldownState.remainingCooldown(type: type)
            if remaining > 0 {
                newTimers[type] = remaining
            }
        }
        cooldownTimers = newTimers
    }

    private func spriteMoodText(for sprite: Sprite) -> String {
        switch sprite.mood {
        case .happy: return "开心"
        case .excited: return "超开心"
        case .worried: return "担心"
        case .sad: return "难过"
        case .sleeping: return "睡觉"
        }
    }

    private func moodColor(for sprite: Sprite) -> Color {
        switch sprite.mood {
        case .happy, .excited: return PixelPalette.greenPrimary
        case .worried: return PixelPalette.orangeWarn
        case .sad: return PixelPalette.redDanger
        case .sleeping: return PixelPalette.purpleNight
        }
    }

    private func checkAndScheduleReminders(plant: Plant) {
        if plant.waterLevel < 0.3 {
            NotificationManager.shared.scheduleWaterReminder(plantName: plant.name, intervalHours: 4)
        }
        if plant.lightLevel < 0.3 {
            NotificationManager.shared.scheduleLightReminder(plantName: plant.name)
        }
    }

    private func ensureDefaultData() {
        if plants.isEmpty { modelContext.insert(Plant.createDefault()) }
        if sprites.isEmpty { modelContext.insert(Sprite.createDefault()) }
        if wallets.isEmpty { modelContext.insert(PlayerWallet.createDefault()) }
    }

    private func colorForType(_ type: InteractionType) -> Color {
        switch type {
        case .water: return PixelPalette.blueWater
        case .light: return PixelPalette.yellowSun
        case .fertilize: return PixelPalette.brownEarth
        case .touch: return PixelPalette.pinkLove
        case .talk: return PixelPalette.purpleNight
        case .sing: return PixelPalette.pinkLove
        case .heal: return PixelPalette.greenLight
        case .play: return PixelPalette.orangeWarn
        case .shield: return PixelPalette.blueWater
        case .dance: return PixelPalette.pinkLove
        case .pet: return Color.brown
        }
    }

    private func splitIntoRows(_ items: [InteractionType], columns: Int) -> [[InteractionType]] {
        var rows: [[InteractionType]] = []
        var index = 0
        while index < items.count {
            let end = min(index + columns, items.count)
            rows.append(Array(items[index..<end]))
            index = end
        }
        return rows
    }
}
