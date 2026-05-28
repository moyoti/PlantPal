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
    @State private var interactionTab: InteractionTab = .care
    private let cooldownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var plant: Plant? { plants.first }
    private var sprite: Sprite? { sprites.first }
    private var wallet: PlayerWallet? { wallets.first }
    
    enum InteractionTab: String, CaseIterable {
        case care = "照料"
        case play = "互动"
    }
    
    private let careInteractions: [InteractionType] = [.water, .light, .fertilize, .heal, .shield]
    private let playInteractions: [InteractionType] = [.touch, .talk, .sing, .play, .dance, .pet]
    
    var body: some View {
        GeometryReader { geo in
            let sceneHeight = geo.size.height * 0.36
            
            ZStack {
                LinearGradient(
                    colors: [PixelPalette.greenBg, PixelPalette.cream],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 4) {
                    pixelHeader
                    
                    if let plant, let sprite {
                        spriteStatusView(sprite, wallet, plant)
                        
                        plantSceneView(plant, sprite, height: sceneHeight)
                        
                        compactStatusBars(plant)
                        
                        interactionSection(plant, sprite)
                    } else {
                        ProgressView("加载中...")
                            .font(PixelFonts.header(size: 10))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 2)
            }
        }
        .onAppear {
            ensureDefaultData()
            if let plant, let sprite {
                timeEngine.calculateTimeEffects(plant: plant, sprite: sprite, wallet: wallet)
            }
            startAmbientAnimations()
        }
        .onReceive(cooldownTimer) { _ in
            updateCooldowns()
        }
    }
    
    // MARK: - Header
    
    private var pixelHeader: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text("我的花园")
                    .font(PixelFonts.header(size: 13))
                    .foregroundColor(PixelPalette.darkText)
                Rectangle().fill(PixelPalette.greenPrimary).frame(height: 2).frame(width: 72)
            }
            Spacer()
            
            if let wallet {
                HStack(spacing: 2) {
                    Circle().fill(PixelPalette.yellowSun).frame(width: 8, height: 8)
                    Text("\(wallet.coins)")
                        .font(PixelFonts.header(size: 7))
                        .foregroundColor(PixelPalette.darkText)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(PixelPalette.yellowSun.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 1).stroke(PixelPalette.yellowSun.opacity(0.5), lineWidth: 1))
            }
        }
    }
    
    // MARK: - Status
    
    private func spriteStatusView(_ sprite: Sprite, _ wallet: PlayerWallet?, _ plant: Plant) -> some View {
        HStack(spacing: 4) {
            Text(sprite.name)
                .font(PixelFonts.header(size: 9))
                .foregroundColor(PixelPalette.greenPrimary)
            
            PixelBadge(text: spriteMoodText(for: sprite), color: moodColor(for: sprite))
            
            if plant.isSick {
                PixelBadge(text: "生病", color: PixelPalette.redDanger)
            }
            
            if Date.now < plant.shieldedUntil {
                PixelBadge(text: "护盾", color: PixelPalette.blueWater)
            }
            
            Spacer()
            
            if sprite.fatigue > 0.3 {
                HStack(spacing: 1) {
                    Text("疲惫")
                        .font(PixelFonts.header(size: 6))
                        .foregroundColor(PixelPalette.orangeWarn)
                    Rectangle()
                        .fill(PixelPalette.orangeWarn.opacity(0.3))
                        .frame(width: 20, height: 4)
                        .overlay(
                            Rectangle().fill(PixelPalette.orangeWarn)
                                .frame(width: 20 * min(sprite.fatigue, 1.0), height: 4)
                        )
                }
            }
        }
    }
    
    // MARK: - Scene
    
    private func plantSceneView(_ plant: Plant, _ sprite: Sprite, height: CGFloat) -> some View {
        ZStack {
            PixelArtImage(name: "bg_\(plant.backgroundScene)", width: nil, height: height)
                .clipped()
            
            floatingClouds
            ambientSparkle
            
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", width: min(120, height * 0.5), height: min(160, height * 0.65))
                        .offset(y: -height * 0.07)
                        .rotationEffect(.degrees(Double(plantSway)), anchor: .bottom)
                    Spacer()
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PixelArtImage(name: "pot_\(plant.potStyle)", width: min(100, height * 0.45), height: min(50, height * 0.2))
                    Spacer()
                }
            }
            
            AnimatedSpriteView(evolutionLevel: sprite.evolutionLevel, mood: sprite.mood, outfitName: sprite.outfit)
                .offset(x: height * 0.15, y: -height * 0.1 + spriteBob)
            
            if let effect = activeEffect {
                InteractionEffectView(type: effect)
            }
        }
        .frame(height: height)
        .pixelCard()
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
    
    // MARK: - Status Bars
    
    private func compactStatusBars(_ plant: Plant) -> some View {
        VStack(spacing: 3) {
            PixelProgressBar(label: "水", value: plant.waterLevel, color: PixelPalette.blueWater)
            PixelProgressBar(label: "光", value: plant.lightLevel, color: PixelPalette.yellowSun)
            PixelProgressBar(label: "命", value: plant.health, color: PixelPalette.greenLight)
        }
    }
    
    // MARK: - Interaction Section
    
    private func interactionSection(_ plant: Plant, _ sprite: Sprite) -> some View {
        VStack(spacing: 4) {
            tabSelector
            
            let interactions = interactionTab == .care ? careInteractions : playInteractions
            interactionGrid(interactions, plant, sprite)
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(InteractionTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        interactionTab = tab
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: tab == .care ? "leaf.fill" : "heart.fill")
                            .font(.system(size: 9))
                        Text(tab.rawValue)
                            .font(PixelFonts.header(size: 8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(interactionTab == tab ? PixelPalette.greenPrimary.opacity(0.15) : Color.clear)
                    .foregroundColor(interactionTab == tab ? PixelPalette.greenPrimary : PixelPalette.mutedText)
                    .overlay(
                        Rectangle()
                            .fill(interactionTab == tab ? PixelPalette.greenPrimary : PixelPalette.cardBorder.opacity(0.3))
                            .frame(height: interactionTab == tab ? 2 : 1),
                        alignment: .bottom
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(PixelPalette.greenBg.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(PixelPalette.cardBorder.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func interactionGrid(_ types: [InteractionType], _ plant: Plant, _ sprite: Sprite) -> some View {
        let columns = types.count <= 5 ? types.count : 5
        let rows = (types.count + columns - 1) / columns
        
        return VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { rowIndex in
                let start = rowIndex * columns
                let end = min(start + columns, types.count)
                let rowTypes = Array(types[start..<end])
                
                HStack(spacing: 4) {
                    ForEach(rowTypes, id: \.self) { type in
                        interactionButton(type, plant, sprite)
                    }
                }
            }
        }
    }
    
    private func interactionButton(_ type: InteractionType, _ plant: Plant, _ sprite: Sprite) -> some View {
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
            VStack(spacing: 3) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(btnColor.opacity(onCooldown ? 0.04 : 0.12))
                        .frame(width: 40, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(btnColor.opacity(onCooldown ? 0.15 : 0.4), lineWidth: onCooldown ? 1 : 2)
                        )
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(onCooldown ? PixelPalette.mutedText : btnColor)
                    
                    if onCooldown {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 40, height: 32)
                            .overlay(
                                Text("\(Int(ceil(remaining)))")
                                    .font(PixelFonts.header(size: 9))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                Text(type.displayName)
                    .font(PixelFonts.header(size: 7))
                    .foregroundColor(onCooldown ? PixelPalette.mutedText : PixelPalette.darkText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .opacity(onCooldown ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(onCooldown)
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
    
    // MARK: - Animations & Helpers
    
    private func startAmbientAnimations() {
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { cloudOffset = 200 }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { plantSway = 2 }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { spriteBob = -4 }
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { sparklePhase = .pi * 2 }
    }
    
    private func updateCooldowns() {
        var newTimers: [InteractionType: Double] = [:]
        for type in careInteractions + playInteractions {
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
    
    private func ensureDefaultData() {
        if plants.isEmpty { modelContext.insert(Plant.createDefault()) }
        if sprites.isEmpty { modelContext.insert(Sprite.createDefault()) }
        if wallets.isEmpty { modelContext.insert(PlayerWallet.createDefault()) }
    }
}