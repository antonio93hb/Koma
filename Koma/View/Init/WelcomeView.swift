import SwiftUI

struct WelcomeView: View {
    @Environment(RootManager.self) var rootManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {

            VStack {
                Image(colorScheme == .dark ? "logoKomaLight" : "logoKomaDark")                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .bold()
                    .padding()
                
                Text("welcome")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                    .bold()
                
                Text("explore_manga")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button {
                    rootManager.currentView = .login
                } label: {
                    Text("login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .cornerRadius(10)
                        .padding(.top, 80)
                        .padding(.horizontal)
                }
                
                Text("developed_with")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .padding()
            .background(colorScheme == .dark ? .black : .white)
            .ignoresSafeArea()
    }
}


#Preview {
    WelcomeView()
        .environment(RootManager())
}
