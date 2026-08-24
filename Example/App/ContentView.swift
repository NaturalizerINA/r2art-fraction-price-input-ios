import SwiftUI
import FractionPriceCore

public struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var language: AppLanguage = .indonesian
    @State private var colorSchemePreference: ColorSchemePreference = .system
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                SwiftUIShowcaseView(language: $language)
                    .tabItem {
                        Label("SwiftUI", systemImage: "swift")
                    }
                    .tag(0)
                
                UIKitShowcaseView(language: $language)
                    .tabItem {
                        Label("UIKit", systemImage: "square.stack.3d.up")
                    }
                    .tag(1)
            }
            .navigationTitle("Fraction Price Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(AppLanguage.allCases) { lang in
                            Button(action: {
                                language = lang
                            }) {
                                HStack {
                                    Text(lang.displayName)
                                    if language == lang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(language == .indonesian ? "🇮🇩 ID" : "🇬🇧 EN")
                                .font(.system(size: 13, weight: .bold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { colorSchemePreference = .system }) {
                            Label("System Theme", systemImage: "circle.lefthalf.filled")
                        }
                        Button(action: { colorSchemePreference = .light }) {
                            Label("Light Mode", systemImage: "sun.max.fill")
                        }
                        Button(action: { colorSchemePreference = .dark }) {
                            Label("Dark Mode", systemImage: "moon.fill")
                        }
                    } label: {
                        Image(systemName: colorSchemePreference.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(6)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(colorSchemePreference.colorScheme)
    }
}

private enum ColorSchemePreference {
    case system
    case light
    case dark
    
    var colorScheme: ColorScheme? {
        switch self {\
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
