import SwiftUI

struct PixelTabBarView: View {
    @Binding var selectedTab: Tab
    let content: AnyView

    init(selectedTab: Binding<Tab>, @ViewBuilder content: () -> some View) {
        self._selectedTab = selectedTab
        self.content = AnyView(content())
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(PixelPalette.greenDark)
                .frame(height: 3)

            HStack(spacing: 0) {
                tabItem(tab: .garden, iconName: "tab_garden", label: "花园")
                tabItem(tab: .collection, iconName: "tab_collection", label: "收藏")
                tabItem(tab: .settings, iconName: "tab_settings", label: "设置")
            }
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [PixelPalette.cream, PixelPalette.creamDark],
                    startPoint: .center, endPoint: .trailing
                )
            )
            .overlay(
                PixelBorder(thickness: 2, cornerSize: 0)
                    .stroke(PixelPalette.cardBorder.opacity(0.5), lineWidth: 2),
                alignment: .top
            )
        }
    }

    private func tabItem(tab: Tab, iconName: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                PixelArtImage(name: iconName, width: 24, height: 24)
                    .opacity(selectedTab == tab ? 1.0 : 0.5)
                Text(label)
                    .font(PixelFonts.header(size: 8))
                    .foregroundColor(selectedTab == tab ? PixelPalette.greenDark : PixelPalette.mutedText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                selectedTab == tab
                    ? PixelPalette.greenPrimary.opacity(0.2)
                    : Color.clear
            )
            .overlay(
                selectedTab == tab
                    ? Rectangle()
                        .fill(PixelPalette.greenDark)
                        .frame(height: 3)
                        .offset(y: -23)
                    : nil
            )
            .scaleEffect(selectedTab == tab ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
