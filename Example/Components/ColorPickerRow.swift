import SwiftUI

/// Color picker row displaying swatch, label, hex value, and reset action.
public struct ColorPickerRow: View {
    public let title: String
    public let description: String
    @Binding public var color: Color
    public let defaultColor: Color
    
    public init(
        title: String,
        description: String,
        color: Binding<Color>,
        defaultColor: Color
    ) {
        self.title = title
        self.description = description
        self._color = color
        self.defaultColor = defaultColor
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            ColorPicker("", selection: $color)
                .labelsHidden()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(color.toHex())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(4)
            
            if color.toHex() != defaultColor.toHex() {
                Button(action: {
                    color = defaultColor
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
