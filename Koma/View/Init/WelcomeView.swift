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
                
                Text("Welcome to KOMA")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                    .bold()
                
                Text("Explore manga, authors, genres and much more with ***KOMA***.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button {
                    rootManager.currentView = .login
                } label: {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .cornerRadius(10)
                        .padding(.top, 80)
                        .padding(.horizontal)
                }
                
                Text("*Developed with the **MyManga API*** from **Apple Coding Academy**")
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
