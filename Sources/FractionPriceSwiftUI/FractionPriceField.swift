import SwiftUI
#if canImport(FractionPriceCore)
import FractionPriceCore
#endif

/// Primary declarative input field for fractional stock tick prices in SwiftUI.
@MainActor
public struct FractionPriceField: View {
    @Binding public var value: Double?
    
    public var rule: TickRule
    public var localization: FractionPriceLocalization
    public var emptyPriceError: (@Sendable () -> String)?
    public var belowMinError: (@Sendable (_ minFormatted: String) -> String)?
    public var aboveMaxError: (@Sendable (_ maxFormatted: String) -> String)?
    public var invalidTickError: (@Sendable (_ step: String, _ nearestFormatted: String) -> String)?
    public var isEnabled: Bool
    public var isReadOnly: Bool
    public var autoCorrection: Bool
    public var autoCorrectionDelayMs: UInt64
    public var snapOnBlur: Bool
    public var labelText: String?
    public var labelAlignment: HorizontalAlignment
    public var textAlignment: TextAlignment
    public var prefixText: String?
    public var suffixText: String?
    public var helperText: String?
    public var colors: FractionPriceColors
    public var cornerRadius: CGFloat
    public var buttonCornerRadius: CGFloat
    public var onSubmitted: (@Sendable (Double?) -> Void)?
    
    @State private var textInput: String = ""
    @FocusState private var isFocused: Bool
    @State private var autoCorrectTask: Task<Void, Never>? = nil
    
    public init(
        value: Binding<Double?>,
        rule: TickRule = TieredTickRule.idx(),
        localization: FractionPriceLocalization = .id,
        emptyPriceError: (@Sendable () -> String)? = nil,
        belowMinError: (@Sendable (_ minFormatted: String) -> String)? = nil,
        aboveMaxError: (@Sendable (_ maxFormatted: String) -> String)? = nil,
        invalidTickError: (@Sendable (_ step: String, _ nearestFormatted: String) -> String)? = nil,
        isEnabled: Bool = true,
        isReadOnly: Bool = false,
        autoCorrection: Bool = false,
        autoCorrectionDelayMs: UInt64 = 300,
        snapOnBlur: Bool = true,
        labelText: String? = nil,
        labelAlignment: HorizontalAlignment = .leading,
        textAlignment: TextAlignment = .center,
        prefixText: String? = nil,
        suffixText: String? = nil,
        helperText: String? = nil,
        colors: FractionPriceColors = .default,
        cornerRadius: CGFloat = 10,
        buttonCornerRadius: CGFloat = 8,
        onSubmitted: (@Sendable (Double?) -> Void)? = nil
    ) {
        self._value = value
        self.rule = rule
        self.localization = localization
        self.emptyPriceError = emptyPriceError
        self.belowMinError = belowMinError
        self.aboveMaxError = aboveMaxError
        self.invalidTickError = invalidTickError
        self.isEnabled = isEnabled
        self.isReadOnly = isReadOnly
        self.autoCorrection = autoCorrection
        self.autoCorrectionDelayMs = autoCorrectionDelayMs
        self.snapOnBlur = snapOnBlur
        self.labelText = labelText
        self.labelAlignment = labelAlignment
        self.textAlignment = textAlignment
        self.prefixText = prefixText
        self.suffixText = suffixText
        self.helperText = helperText
        self.colors = colors
        self.cornerRadius = cornerRadius
        self.buttonCornerRadius = buttonCornerRadius
        self.onSubmitted = onSubmitted
    }
    
    private var effectiveLocalization: FractionPriceLocalization {
        localization.copyWith(
            emptyPriceError: emptyPriceError,
            belowMinError: belowMinError,
            aboveMaxError: aboveMaxError,
            invalidTickError: invalidTickError
        )
    }
    
    private var validationResult: PriceValidationResult {
        rule.validatePrice(value, localization: effectiveLocalization)
    }
    
    private var activeBorderColor: Color {
        if !validationResult.isValid {
            return colors.errorBorderColor
        }
        if isFocused {
            return colors.focusedBorderColor
        }
        return colors.unfocusedBorderColor
    }
    
    public var body: some View {
        VStack(alignment: labelAlignment, spacing: 6) {
            // 1. Label Text
            if let label = labelText ?? (labelText == nil ? nil : effectiveLocalization.labelText) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(colors.labelColor)
            }
            
            // 2. Segmented Card Container
            HStack(spacing: 0) {
                // Minus Stepper Button
                StepperHoldButton(
                    isEnabled: isEnabled && !isReadOnly,
                    action: { stepDown() }
                ) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colors.buttonIconColor)
                        .frame(width: 44, height: 44)
                        .background(colors.buttonContainerColor)
                        .cornerRadius(buttonCornerRadius)
                }
                
                // Prefix Text
                if let prefix = prefixText, !prefix.isEmpty {
                    Text(prefix)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(colors.helperColor)
                        .padding(.leading, 12)
                        .padding(.trailing, 6)
                }
                
                // Center Editable Text Field
                TextField(
                    "0",
                    text: Binding(
                        get: { textInput },
                        set: { newText in
                            handleTextChange(newText)
                        }
                    )
                )
                .id(effectiveLocalization.locale.identifier)
                .applyNumberKeyboard()
                .multilineTextAlignment(textAlignment)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colors.textColor)
                .disabled(!isEnabled || isReadOnly)
                .focused($isFocused)
                .onSubmit {
                    onSubmitted?(value)
                }
                .padding(.horizontal, (prefixText?.isEmpty ?? true) && (suffixText?.isEmpty ?? true) ? 12 : 4)
                .frame(maxWidth: .infinity)
                
                // Suffix Text
                if let suffix = suffixText, !suffix.isEmpty {
                    Text(suffix)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(colors.helperColor)
                        .padding(.leading, 6)
                        .padding(.trailing, 12)
                }
                
                // Plus Stepper Button
                StepperHoldButton(
                    isEnabled: isEnabled && !isReadOnly,
                    action: { stepUp() }
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colors.buttonIconColor)
                        .frame(width: 44, height: 44)
                        .background(colors.buttonContainerColor)
                        .cornerRadius(buttonCornerRadius)
                }
            }
            .background(colors.containerColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(activeBorderColor, lineWidth: isFocused || !validationResult.isValid ? 1.5 : 1.0)
            )
            
            // 3. Error or Helper Text Info
            Group {
                if !validationResult.isValid, let error = validationResult.errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(colors.errorColor)
                        .transition(.opacity)
                } else if let helper = helperText, !helper.isEmpty {
                    Text(helper)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(colors.helperColor)
                } else if let val = value, let step = validationResult.currentStep ?? Optional(rule.getTickSize(for: val)) {
                    let formattedStep = rule.formatPrice(step, locale: effectiveLocalization.locale, currencySymbol: effectiveLocalization.currencySymbol)
                    Text("\(effectiveLocalization.labelText): \(formattedStep)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(colors.helperColor)
                }
            }
            .padding(.horizontal, 2)
        }
        .onAppear {
            syncFromValue()
        }
        .onChange(of: value) { _ in
            if !isFocused {
                syncFromValue()
            }
        }
        .onChange(of: localization.locale.identifier) { _ in
            if !isFocused {
                syncFromValue()
            }
        }
        .onChange(of: effectiveLocalization.locale.identifier) { _ in
            if !isFocused {
                syncFromValue()
            }
        }
        .onChange(of: isFocused) { focused in
            if !focused {
                handleBlur()
            }
        }
    }
    
    private func syncFromValue() {
        if let val = value {
            textInput = rule.formatPrice(val, locale: effectiveLocalization.locale)
        } else {
            textInput = ""
        }
    }
    
    private func handleTextChange(_ newText: String) {
        textInput = newText
        let parsed = rule.parsePrice(newText, locale: effectiveLocalization.locale)
        value = parsed
        
        if autoCorrection, let p = parsed, !rule.isValidTick(price: p) {
            autoCorrectTask?.cancel()
            autoCorrectTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: autoCorrectionDelayMs * 1_000_000)
                guard !Task.isCancelled else { return }
                let snapped = rule.snapToTick(price: p, mode: .nearest)
                value = snapped
                textInput = rule.formatPrice(snapped, locale: effectiveLocalization.locale)
            }
        }
    }
    
    private func handleBlur() {
        autoCorrectTask?.cancel()
        if snapOnBlur, let p = value {
            let snapped = rule.snapToTick(price: p, mode: .nearest)
            value = snapped
            textInput = rule.formatPrice(snapped, locale: effectiveLocalization.locale)
        } else {
            syncFromValue()
        }
    }
    
    private func stepUp() {
        autoCorrectTask?.cancel()
        let base = value ?? rule.minPrice ?? 0.0
        let next = rule.nextTick(price: base, ticks: 1)
        value = next
        textInput = rule.formatPrice(next, locale: effectiveLocalization.locale)
    }
    
    private func stepDown() {
        autoCorrectTask?.cancel()
        let base = value ?? rule.minPrice ?? 0.0
        let prev = rule.prevTick(price: base, ticks: 1)
        value = prev
        textInput = rule.formatPrice(prev, locale: effectiveLocalization.locale)
    }
}

private extension View {
    @ViewBuilder
    func applyNumberKeyboard() -> some View {
        #if os(iOS) || os(tvOS) || os(watchOS)
        self.keyboardType(.numberPad)
        #else
        self
        #endif
    }
}
