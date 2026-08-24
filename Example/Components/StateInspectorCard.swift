import SwiftUI
import FractionPriceCore

/// Real-time live state inspector card displaying current parameters, validation result, and event log.
public struct StateInspectorCard: View {
    public let rawPrice: Double?
    public let formattedPrice: String
    public let tickStep: Double?
    public let validationResult: PriceValidationResult
    public let lastEvent: String
    
    public init(
        rawPrice: Double?,
        formattedPrice: String,
        tickStep: Double?,
        validationResult: PriceValidationResult,
        lastEvent: String
    ) {
        self.rawPrice = rawPrice
        self.formattedPrice = formattedPrice
        self.tickStep = tickStep
        self.validationResult = validationResult
        self.lastEvent = lastEvent
    }
    
    private var statusColor: Color {
        switch validationResult.status {
        case .valid: return .green
        case .empty: return .orange
        case .belowMin, .aboveMax: return .red
        case .invalidTick: return .yellow
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "gauge.with.needle")
                    .foregroundColor(.blue)
                Text("Live State Inspector")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                
                // Status Badge
                Text(validationResult.status.rawValue.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(6)
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                InfoCell(title: "Raw Value", value: rawPrice != nil ? String(format: "%.2f", rawPrice!) : "nil")
                InfoCell(title: "Formatted Text", value: formattedPrice.isEmpty ? "—" : formattedPrice)
                InfoCell(title: "Active Tick Step", value: tickStep != nil ? String(format: "%.0f", tickStep!) : "—")
                InfoCell(title: "Is Valid", value: validationResult.isValid ? "✅ true" : "❌ false")
            }
            
            if !validationResult.isValid, let error = validationResult.errorMessage {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
            
            if !lastEvent.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 11))
                    Text("Last Event: \(lastEvent)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor { trait in
                    trait.userInterfaceStyle == .dark
                        ? UIColor(red: 0.10, green: 0.13, blue: 0.18, alpha: 1.0)
                        : UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
                }))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct InfoCell: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(6)
    }
}
