import SwiftUI
import UIKit

struct SpriteAnimationData {
    let idleFrames: [String]
    let happyFrames: [String]
    let worriedFrames: [String]
    let sleepingFrames: [String]
    let sadFrames: [String]
    let frameDuration: Double
    
    static func framesFor(evolutionLevel: Int) -> SpriteAnimationData {
        switch evolutionLevel {
        case 1:
            return SpriteAnimationData(
                idleFrames: ["sprite_1_idle_1", "sprite_1_idle_2", "sprite_1_idle_3", "sprite_1_idle_4"],
                happyFrames: ["sprite_1_happy_1", "sprite_1_happy_2", "sprite_1_happy_3", "sprite_1_happy_4"],
                worriedFrames: ["sprite_1_worried_1", "sprite_1_worried_2"],
                sleepingFrames: ["sprite_1_sleep_1", "sprite_1_sleep_2", "sprite_1_sleep_3", "sprite_1_sleep_4"],
                sadFrames: ["sprite_1_sad_1", "sprite_1_sad_2", "sprite_1_sad_3", "sprite_1_sad_4"],
                frameDuration: 0.25
            )
        case 2:
            return SpriteAnimationData(
                idleFrames: ["sprite_2_idle_1", "sprite_2_idle_2", "sprite_2_idle_3", "sprite_2_idle_4", "sprite_2_idle_5", "sprite_2_idle_6"],
                happyFrames: ["sprite_2_happy_1", "sprite_2_happy_2", "sprite_2_happy_3", "sprite_2_happy_4", "sprite_2_happy_5", "sprite_2_happy_6"],
                worriedFrames: ["sprite_2_worried_1", "sprite_2_worried_2", "sprite_2_worried_3"],
                sleepingFrames: ["sprite_2_sleep_1", "sprite_2_sleep_2", "sprite_2_sleep_3", "sprite_2_sleep_4"],
                sadFrames: ["sprite_2_sad_1", "sprite_2_sad_2", "sprite_2_sad_3", "sprite_2_sad_4"],
                frameDuration: 0.2
            )
        case 3:
            return SpriteAnimationData(
                idleFrames: (1...6).map { "sprite_3_idle_\($0)" },
                happyFrames: (1...6).map { "sprite_3_happy_\($0)" },
                worriedFrames: (1...4).map { "sprite_3_worried_\($0)" },
                sleepingFrames: (1...4).map { "sprite_3_sleep_\($0)" },
                sadFrames: (1...4).map { "sprite_3_sad_\($0)" },
                frameDuration: 0.2
            )
        case 4:
            return SpriteAnimationData(
                idleFrames: (1...8).map { "sprite_4_idle_\($0)" },
                happyFrames: (1...8).map { "sprite_4_happy_\($0)" },
                worriedFrames: (1...4).map { "sprite_4_worried_\($0)" },
                sleepingFrames: (1...4).map { "sprite_4_sleep_\($0)" },
                sadFrames: (1...4).map { "sprite_4_sad_\($0)" },
                frameDuration: 0.15
            )
        case 5:
            return SpriteAnimationData(
                idleFrames: (1...8).map { "sprite_5_idle_\($0)" },
                happyFrames: (1...8).map { "sprite_5_happy_\($0)" },
                worriedFrames: (1...4).map { "sprite_5_worried_\($0)" },
                sleepingFrames: (1...4).map { "sprite_5_sleep_\($0)" },
                sadFrames: (1...4).map { "sprite_5_sad_\($0)" },
                frameDuration: 0.15
            )
        default:
            return framesFor(evolutionLevel: 1)
        }
    }
    
    func framesForMood(_ mood: SpriteMood) -> [String] {
        switch mood {
        case .happy, .excited: return happyFrames
        case .worried: return worriedFrames
        case .sad: return sadFrames
        case .sleeping: return sleepingFrames
        }
    }
}

struct AnimatedSpriteView: View {
    let evolutionLevel: Int
    let mood: SpriteMood
    var outfitName: String = "default"
    @State private var currentFrameIndex: Int = 0
    
    private let animationData: SpriteAnimationData
    
    init(evolutionLevel: Int, mood: SpriteMood, outfitName: String = "default") {
        self.evolutionLevel = evolutionLevel
        self.mood = mood
        self.outfitName = outfitName
        self.animationData = SpriteAnimationData.framesFor(evolutionLevel: evolutionLevel)
    }
    
    var body: some View {
        let frames = animationData.framesForMood(mood)
        let frameName = frames.indices.contains(currentFrameIndex) ? frames[currentFrameIndex] : frames[0]
        
        ZStack {
            PixelArtImage(name: frameName, size: .sprite)
            
            if outfitName != "default" {
                PixelArtImage(name: "outfit_\(outfitName)", size: .sprite)
            }
        }
        .onAppear {
            currentFrameIndex = 0
            animateFrames(frameCount: frames.count)
        }
        .onChange(of: mood) { _, _ in
            currentFrameIndex = 0
            animateFrames(frameCount: frames.count)
        }
        .onChange(of: evolutionLevel) { _, _ in
            currentFrameIndex = 0
        }
    }
    
    private func animateFrames(frameCount: Int) {
        guard frameCount > 1 else { return }
        Task {
            while true {
                try? await Task.sleep(for: .milliseconds(Int(animationData.frameDuration * 1000)))
                currentFrameIndex = (currentFrameIndex + 1) % frameCount
            }
        }
    }
}

struct AnimatedPetView: View {
    let petType: PetType
    let isHappy: Bool
    @State private var currentFrameIndex: Int = 0
    @State private var animationTask: Task<Void, Never>?
    
    private var frames: [String] {
        let mood = isHappy ? "happy" : "idle"
        return (1...4).map { "pet_\(petType.rawValue.replacingOccurrences(of: "_sprite", with: ""))_\(mood)_\($0)" }
    }
    
    var body: some View {
        let frameName = frames.indices.contains(currentFrameIndex) ? frames[currentFrameIndex] : frames[0]
        PixelArtImage(name: frameName, size: .sprite)
            .onAppear { startAnimation() }
            .onChange(of: isHappy) { _, _ in currentFrameIndex = 0; startAnimation() }
    }
    
    private func startAnimation() {
        animationTask?.cancel()
        animationTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                currentFrameIndex = (currentFrameIndex + 1) % frames.count
            }
        }
    }
}

struct InteractionEffectView: View {
    let type: InteractionType
    @State private var isAnimating = false
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            switch type {
            case .water: waterDropsView
            case .light: sparklesView
            case .fertilize: glowView
            case .touch: heartsView
            case .talk: bubblesView
            case .sing: musicNotesView
            case .heal: healCrossView
            case .play: gameIconsView
            case .shield: shieldAuraView
            case .dance: danceStarsView
            case .pet: petSparklesView
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
            }
        }
    }
    
    private var waterDropsView: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(PixelPalette.blueWater)
                    .frame(width: 6, height: 8)
                    .offset(
                        x: CGFloat([-24, -12, 0, 12, 24, -18, 6, 18][i]),
                        y: isAnimating ? CGFloat(60 + i * 5) : CGFloat(-30 + i * 4)
                    )
            }
        }
    }
    
    private var sparklesView: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                Rectangle()
                    .fill(i % 2 == 0 ? PixelPalette.yellowSun : PixelPalette.orangeWarn)
                    .frame(width: 5, height: 5)
                    .rotationEffect(.degrees(45))
                    .offset(
                        x: isAnimating ? CGFloat([-40, -20, 0, 20, 40, -30, -10, 10, 30, 0][i]) : 0,
                        y: isAnimating ? CGFloat([-60, -40, -20, -50, -30, -10, -55, -35, -15, -45][i]) : 0
                    )
                    .scaleEffect(isAnimating ? 1.8 : 0.3)
            }
        }
    }
    
    private var glowView: some View {
        ZStack {
            Circle()
                .fill(PixelPalette.brownEarth.opacity(0.25))
                .frame(width: isAnimating ? 90 : 20, height: isAnimating ? 90 : 20)
            
            glowParticles
        }
    }
    
    private var glowParticles: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) / 6.0
                let dx: CGFloat = cos(.pi * 2 * angle) * 40
                let dy: CGFloat = sin(.pi * 2 * angle) * 40
                Circle()
                    .fill(PixelPalette.greenLight.opacity(0.5))
                    .frame(width: 4, height: 4)
                    .offset(x: isAnimating ? dx : 0, y: isAnimating ? dy : 0)
            }
        }
    }
    
    private var heartsView: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                pixelHeart
                    .offset(
                        x: CGFloat([-20, -8, 8, 20, -14, 14][i]),
                        y: isAnimating ? CGFloat(-40 - i * 8) : 0
                    )
            }
        }
    }
    
    private var pixelHeart: some View {
        ZStack {
            Rectangle().fill(PixelPalette.pinkLove).frame(width: 4, height: 4)
                .offset(x: -3, y: -3)
            Rectangle().fill(PixelPalette.pinkLove).frame(width: 4, height: 4)
                .offset(x: 3, y: -3)
            Rectangle().fill(PixelPalette.pinkLove).frame(width: 8, height: 6)
                .offset(y: 2)
        }
    }
    
    private var bubblesView: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .stroke(PixelPalette.purpleNight, lineWidth: 2)
                    .frame(width: 20, height: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(PixelPalette.cream)
                    )
                    .offset(
                        x: CGFloat([-20, 0, 20][i]),
                        y: isAnimating ? CGFloat(-30 - i * 15) : 10
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
            }
        }
    }
    
    private var musicNotesView: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Text(i % 2 == 0 ? "♪" : "♫")
                    .font(.system(size: 14))
                    .foregroundColor(PixelPalette.pinkLove)
                    .offset(
                        x: CGFloat([-30, -10, 10, 30, -20, 20][i]),
                        y: isAnimating ? CGFloat(-50 - i * 12) : CGFloat(20 + i * 5)
                    )
                    .rotationEffect(.degrees(isAnimating ? Double(i) * 15 : 0))
                    .scaleEffect(isAnimating ? 1.2 : 0.4)
            }
        }
    }
    
    private var healCrossView: some View {
        ZStack {
            Circle()
                .fill(PixelPalette.greenLight.opacity(0.2))
                .frame(width: isAnimating ? 100 : 30, height: isAnimating ? 100 : 30)
            
            Rectangle()
                .fill(PixelPalette.greenLight)
                .frame(width: 6, height: 20)
            
            Rectangle()
                .fill(PixelPalette.greenLight)
                .frame(width: 20, height: 6)
            
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(PixelPalette.greenLight.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat([20, -20, 20, -20][i]),
                        y: CGFloat([20, 20, -20, -20][i])
                    )
                    .scaleEffect(isAnimating ? 1.5 : 0.3)
            }
        }
    }
    
    private var gameIconsView: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? PixelPalette.orangeWarn : (i % 3 == 1 ? PixelPalette.yellowSun : PixelPalette.greenLight))
                    .frame(width: 5, height: 5)
                    .rotationEffect(.degrees(isAnimating ? Double(i) * 45 : 0))
                    .offset(
                        x: isAnimating ? CGFloat([-35, -25, 0, 25, 35, -15, 15, 0][i]) : 0,
                        y: isAnimating ? CGFloat([-35, -10, -25, -10, -35, 0, 0, -20][i]) : 0
                    )
                    .scaleEffect(isAnimating ? 1.5 : 0.3)
            }
            
            RoundedRectangle(cornerRadius: 2)
                .fill(PixelPalette.orangeWarn.opacity(0.15))
                .frame(width: isAnimating ? 60 : 0, height: isAnimating ? 60 : 0)
        }
    }
    
    private var shieldAuraView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(PixelPalette.blueWater.opacity(isAnimating ? 0.6 : 0.1), lineWidth: 3)
                .frame(width: isAnimating ? 80 : 30, height: isAnimating ? 80 : 30)
            
            RoundedRectangle(cornerRadius: 6)
                .stroke(PixelPalette.blueWater.opacity(isAnimating ? 0.3 : 0.05), lineWidth: 2)
                .frame(width: isAnimating ? 100 : 20, height: isAnimating ? 100 : 20)
            
            Rectangle()
                .fill(PixelPalette.blueWater)
                .frame(width: 10, height: 14)
                .overlay(
                    Rectangle().fill(PixelPalette.blueWater).frame(width: 14, height: 4)
                )
                .scaleEffect(isAnimating ? 1.2 : 0.4)
        }
    }
    
    private var danceStarsView: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                let angle = Double(i) / 10.0
                let radius: CGFloat = isAnimating ? CGFloat(30 + i * 5) : 0
                Rectangle()
                    .fill(i % 2 == 0 ? PixelPalette.pinkLove : PixelPalette.yellowSun)
                    .frame(width: 4, height: 4)
                    .rotationEffect(.degrees(45))
                    .offset(
                        x: cos(.pi * 2 * angle) * radius,
                        y: sin(.pi * 2 * angle) * radius
                    )
                    .scaleEffect(isAnimating ? 1.3 : 0.2)
            }
            
            Circle()
                .fill(PixelPalette.pinkLove.opacity(0.1))
                .frame(width: isAnimating ? 60 : 0, height: isAnimating ? 60 : 0)
        }
    }
    
    private var petSparklesView: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Rectangle()
                    .fill(PixelPalette.cream.opacity(0.7))
                    .frame(width: 3, height: 3)
                    .rotationEffect(.degrees(45))
                    .offset(
                        x: CGFloat([-15, -8, 8, 15, 0][i]),
                        y: isAnimating ? CGFloat(-20 - i * 10) : CGFloat(5 + i * 3)
                    )
                    .scaleEffect(isAnimating ? 1.5 : 0.3)
            }
            
            ForEach(0..<3, id: \.self) { i in
                Rectangle()
                    .fill(PixelPalette.greenLight.opacity(0.5))
                    .frame(width: 2, height: 6)
                    .offset(
                        x: CGFloat([-12, 0, 12][i]),
                        y: isAnimating ? CGFloat(-15 - i * 8) : 0
                    )
            }
        }
    }
}