import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [HabitTask]
    @Query private var plants: [Plant]
    @Query private var sprites: [Sprite]
    @Query private var wallets: [PlayerWallet]
    @State private var showAddSheet = false
    
    private var plant: Plant? { plants.first }
    private var sprite: Sprite? { sprites.first }
    private var wallet: PlayerWallet? { wallets.first }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PixelPalette.greenBg, PixelPalette.cream],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                pixelHeader
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: PixelSpacing.md) {
                        ForEach(tasks) { task in
                            HabitTaskCard(task: task, plant: plant, sprite: sprite, wallet: wallet)
                        }
                    }
                    .padding(PixelSpacing.lg)
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddHabitSheet()
        }
    }
    
    private var pixelHeader: some View {
        HStack {
            VStack(spacing: PixelSpacing.xs) {
                Text("习惯任务")
                    .font(PixelFonts.header(size: 14))
                    .foregroundColor(PixelPalette.darkText)
                Rectangle()
                    .fill(PixelPalette.greenPrimary)
                    .frame(height: 3)
                    .frame(width: 100)
            }
            Spacer()
            Button { showAddSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(PixelPalette.greenPrimary)
                    .overlay(PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.greenLight, lineWidth: 2))
            }
        }
        .padding(.horizontal, PixelSpacing.lg)
        .padding(.top, PixelSpacing.md)
    }
}

struct HabitTaskCard: View {
    let task: HabitTask
    let plant: Plant?
    let sprite: Sprite?
    let wallet: PlayerWallet?
    @Environment(\.modelContext) private var modelContext
    @State private var timeEngine = TimeEngine()
    
    var body: some View {
        HStack(spacing: PixelSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(PixelPalette.cream)
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(PixelPalette.cardBorder, lineWidth: 2))
                Text(task.iconEmoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(PixelFonts.body(size: 14))
                    .foregroundColor(PixelPalette.darkText)
                    .strikethrough(task.isCompletedToday, color: PixelPalette.mutedText)
                
                HStack(spacing: 4) {
                    PixelBadge(text: "🔥\(task.streakCount)", color: PixelPalette.orangeWarn)
                    PixelBadge(text: "💧\(Int(task.nutrientReward))", color: PixelPalette.blueWater)
                    PixelBadge(text: "☀️\(Int(task.sunlightReward))", color: PixelPalette.yellowSun)
                }
            }
            
            Spacer()
            
            Button { completeTask() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(PixelPalette.cardBorder, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if task.isCompletedToday {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(PixelPalette.greenPrimary)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(task.isCompletedToday)
        }
        .pixelCard()
    }
    
    private func completeTask() {
        guard !task.isCompletedToday else { return }
        task.isCompletedToday = true
        task.completedAt = Date()
        task.streakCount += 1
        if let plant { timeEngine.applyHabitCompletion(plant: plant, sprite: sprite ?? Sprite(), task: task, wallet: wallet) }
    }
}

struct AddHabitSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var iconEmoji = "💧"
    @State private var nutrientReward = 2
    @State private var sunlightReward = 1
    
    private let emojiOptions = ["💧", "🏃", "🌅", "📚", "🧘", "🍎", "💪", "🎨", "🎵", "🛌"]
    
    var body: some View {
        ZStack {
            PixelPalette.cream.ignoresSafeArea()
            
            VStack(spacing: PixelSpacing.lg) {
                VStack(spacing: PixelSpacing.xs) {
                    Text("添加习惯")
                        .font(PixelFonts.header(size: 14))
                        .foregroundColor(PixelPalette.darkText)
                    Rectangle().fill(PixelPalette.greenPrimary).frame(height: 3).frame(width: 80)
                }
                .padding(.top, PixelSpacing.xl)
                
                VStack(spacing: PixelSpacing.md) {
                    TextField("任务名称", text: $title)
                        .font(PixelFonts.body(size: 14))
                        .padding(PixelSpacing.sm)
                        .background(Color.white)
                        .overlay(PixelBorder(thickness: 2, cornerSize: 4).stroke(PixelPalette.cardBorder, lineWidth: 2))
                    
                    VStack(alignment: .leading, spacing: PixelSpacing.xs) {
                        Text("选择图标")
                            .font(PixelFonts.header(size: 9))
                            .foregroundColor(PixelPalette.mutedText)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: PixelSpacing.sm) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button { iconEmoji = emoji } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(iconEmoji == emoji ? PixelPalette.greenBg : Color.white)
                                                .frame(width: 40, height: 40)
                                                .overlay(RoundedRectangle(cornerRadius: 2).stroke(
                                                    iconEmoji == emoji ? PixelPalette.greenPrimary : PixelPalette.cardBorder, lineWidth: 2))
                                            Text(emoji).font(.system(size: 20))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    PixelStepper(value: $nutrientReward, range: 0...10, label: "养分奖励")
                    PixelStepper(value: $sunlightReward, range: 0...10, label: "阳光奖励")
                }
                .padding(.horizontal, PixelSpacing.lg)
                
                Spacer()
                
                HStack(spacing: PixelSpacing.lg) {
                    PixelButton(icon: "xmark", label: "取消", color: PixelPalette.mutedText) { dismiss() }
                    PixelButton(icon: "checkmark", label: "添加", color: PixelPalette.greenPrimary) {
                        addTask()
                        dismiss()
                    }
                }
                .padding(.horizontal, PixelSpacing.lg)
                .padding(.bottom, PixelSpacing.xl)
            }
        }
    }
    
    private func addTask() {
        let task = HabitTask(title: title, iconEmoji: iconEmoji, nutrientReward: Double(nutrientReward), sunlightReward: Double(sunlightReward))
        modelContext.insert(task)
    }
}
