import SwiftUI

/// Animated accordion dropdown card component.
public struct CollapsibleSection<Content: View>: View {
    public let icon: String
    public let title: String
    public let subtitle: String?
    @Binding public var isExpanded: Bool
    @ViewBuilder public let content: () -> Content
    
    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isExpanded = isExpanded
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let sub = subtitle {
                            Text(sub)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)
                
                VStack(spacing: 14) {
                    content()
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor { trait in
                    trait.userInterfaceStyle == .dark
                        ? UIColor(red: 0.13, green: 0.16, blue: 0.22, alpha: 1.0)
                        : UIColor.white
                }))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
    }
}
