import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("waterReminderInterval") private var waterReminderInterval = 4
    @State private var showResetConfirm = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [PixelPalette.greenBg, PixelPalette.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: PixelSpacing.xl) {
                    pixelHeader
                    notificationSection
                    plantInfoSection
                    aboutSection
                    dangerSection
                }
                .padding(PixelSpacing.lg)
                .padding(.bottom, 60)
            }
            
            if showResetConfirm {
                resetConfirmOverlay
            }
        }
    }
    
    private var pixelHeader: some View {
        VStack(spacing: PixelSpacing.xs) {
            Text("设置").font(PixelFonts.header(size: 16)).foregroundColor(PixelPalette.darkText)
            Rectangle().fill(PixelPalette.greenPrimary).frame(height: 3).frame(width: 60)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var notificationSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "通知")
            VStack(spacing: PixelSpacing.sm) {
                PixelToggle(isOn: $notificationsEnabled, label: "浇水提醒")
                if notificationsEnabled {
                    PixelStepper(value: $waterReminderInterval, range: 1...12, label: "间隔(小时)")
                }
            }
            .pixelCard()
        }
    }
    
    private var plantInfoSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "植物信息")
            if let plant = plants.first {
                VStack(spacing: PixelSpacing.xs) {
                    HStack(spacing: PixelSpacing.sm) {
                        PixelArtImage(name: "plant_\(plant.growthStage.rawValue)", size: .icon)
                        Text(plant.name).font(PixelFonts.header(size: 10)).foregroundColor(PixelPalette.darkText)
                        Spacer()
                    }
                    PixelInfoRow(label: "品种", value: plant.species.displayName)
                    PixelInfoRow(label: "阶段", value: plant.growthStage.displayName)
                    PixelInfoRow(label: "存活", value: "\(plant.totalDaysAlive) 天")
                }
                .pixelCard()
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "关于")
            VStack(spacing: PixelSpacing.xs) {
                PixelInfoRow(label: "版本", value: "1.0.0")
                PixelInfoRow(label: "作者", value: "PlantPal Team")
            }
            .pixelCard()
        }
    }
    
    private var dangerSection: some View {
        VStack(spacing: PixelSpacing.md) {
            PixelSectionHeader(title: "危险操作", color: PixelPalette.redDanger)
            Button { showResetConfirm = true } label: {
                HStack {
                    Image(systemName: "trash").foregroundColor(.white)
                    Text("重置所有数据").font(PixelFonts.header(size: 10)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(PixelSpacing.md)
                .background(PixelPalette.redDanger)
                .overlay(PixelBorder(thickness: 2, cornerSize: 4).stroke(Color.red.opacity(0.5), lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var resetConfirmOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: PixelSpacing.lg) {
                Text("确认重置?").font(PixelFonts.header(size: 12)).foregroundColor(PixelPalette.redDanger)
                Text("所有数据将被删除且无法恢复").font(PixelFonts.body(size: 13)).foregroundColor(PixelPalette.mutedText)
                HStack(spacing: PixelSpacing.lg) {
                    PixelButton(icon: "xmark", label: "取消", color: PixelPalette.mutedText) { showResetConfirm = false }
                    PixelButton(icon: "trash", label: "重置", color: PixelPalette.redDanger) {
                        resetAllData()
                        showResetConfirm = false
                    }
                }
            }
            .padding(PixelSpacing.xl)
            .background(PixelPalette.cream)
            .overlay(PixelBorder(thickness: 3, cornerSize: 6).stroke(PixelPalette.redDanger, lineWidth: 3))
        }
    }
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: InteractionRecord.self)
            try modelContext.delete(model: HabitTask.self)
            try modelContext.delete(model: Sprite.self)
            try modelContext.delete(model: Plant.self)
        } catch { }
    }
}
