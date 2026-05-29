import os

PATH = "/Users/jenkins3/Documents/dqh/AIGenPrj/ios/PlantPal/PlantPal/Views/Garden/GardenView.swift"

content = r"""import SwiftUI
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
                    ProgressView("\u52a0\u8f7d\u4e2d...")
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
"""

with open(PATH, "w") as f:
    f.write(content)
print(f"Written part 1: {len(content)} chars")
