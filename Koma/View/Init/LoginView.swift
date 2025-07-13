import SwiftUI

struct LoginView: View {
    @Environment(RootManager.self) var rootManager
    @State private var animate = false

    var body: some View {
        
        VStack {
            Image(systemName: "faceid")
                .resizable()
                .scaledToFit()
                .symbolEffect(.breathe, isActive: animate)
                .frame(width: 120, height: 120)
                .padding()

            Text("Loading...")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .padding()
        }
        .onAppear {
            animate.toggle()
            Task {
                try? await Task.sleep(for: .seconds(2.2))
                rootManager.currentView = .content
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(RootManager())
}
