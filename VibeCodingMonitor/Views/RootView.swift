import SwiftUI

struct RootView: View {
    @EnvironmentObject private var windowMode: WindowModeManager

    var body: some View {
        Group {
            switch windowMode.mode {
            case .floating:
                FloatingPanelView()
            case .standard:
                ContentView()
            }
        }
        .background(WindowStyleConfigurator())
        .animation(.easeInOut(duration: 0.2), value: windowMode.mode)
    }
}
