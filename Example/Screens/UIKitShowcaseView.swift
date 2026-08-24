import SwiftUI
import UIKit
import FractionPriceCore
import FractionPriceUIKit

/// UIKit showcase screen wrapping `FractionPriceView` via `UIViewRepresentable` to test full feature parity.
public struct UIKitShowcaseView: View {
    @Binding public var language: AppLanguage
    
    // Core State
    @State private var price: Double? = 2450.0
    @State private var lastEvent: String = "Ready"
    
    // Functional Settings
    @State private var isEnabled: Bool = true
    @State private var isReadOnly: Bool = false
    @State private var autoCorrection: Bool = true
    @State private var autoCorrectionDelayMs: Double = 300
    @State private var snapOnBlur: Bool = true
    @State private var cornerRadius: Double = 12
    @State private var buttonCornerRadius: Double = 8
    
    // Label & Alignment
    @State private var labelText: String = ""
    @State private var labelAlignment: NSTextAlignment = .left
    @State private var textAlignment: NSTextAlignment = .center
    @State private var prefixText: String = ""
    @State private var suffixText: String = ""
    @State private var helperText: String = ""
    
    // Custom Errors
    @State private var useCustomErrors: Bool = false
    @State private var customEmptyError: String = ""
    @State private var customBelowMinError: String = ""
    @State private var customAboveMaxError: String = ""
    @State private var customInvalidTickError: String = ""
    
    // Colors
    private let defaultColors = FractionPriceViewColors.default
    @State private var containerColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.16, blue: 0.23, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
    })
    @State private var textColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
    })
    @State private var labelColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.58, green: 0.64, blue: 0.72, alpha: 1.0)
            : UIColor(red: 0.39, green: 0.45, blue: 0.55, alpha: 1.0)
    })
    @State private var helperColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.45, green: 0.52, blue: 0.62, alpha: 1.0)
            : UIColor(red: 0.52, green: 0.59, blue: 0.67, alpha: 1.0)
    })
    @State private var errorColor: Color = Color(red: 0.94, green: 0.27, blue: 0.27)
    @State private var buttonContainerColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.25, blue: 0.33, alpha: 1.0)
            : UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
    })
    @State private var buttonIconColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
            : UIColor(red: 0.01, green: 0.47, blue: 0.98, alpha: 1.0)
    })
    @State private var unfocusedBorderColor: Color = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.28, green: 0.33, blue: 0.41, alpha: 1.0)
            : UIColor(red: 0.82, green: 0.85, blue: 0.89, alpha: 1.0)
    })
    @State private var focusedBorderColor: Color = Color(red: 0.22, green: 0.74, blue: 0.97)
    @State private var errorBorderColor: Color = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    // Accordion Expansion States
    @State private var isFunctionalExpanded: Bool = true
    @State private var isColorsExpanded: Bool = false
    @State private var isLabelsExpanded: Bool = false
    @State private var isLocalizationExpanded: Bool = false
    
    public init(language: Binding<AppLanguage>) {
        self._language = language
    }
    
    private var activeRule: TickRule {
        TieredTickRule.idx()
    }
    
    private var activeLocalization: FractionPriceLocalization {
        if useCustomErrors {
            return language.localization.copyWith(
                emptyPriceError: { customEmptyError },
                belowMinError: { min in customBelowMinError.replacingOccurrences(of: "{min}", with: min) },
                aboveMaxError: { max in customAboveMaxError.replacingOccurrences(of: "{max}", with: max) },
                invalidTickError: { step, nearest in
                    customInvalidTickError
                        .replacingOccurrences(of: "{step}", with: step)
                        .replacingOccurrences(of: "{nearest}", with: nearest)
                }
            )
        }
        return language.localization
    }
    
    private var activeColors: FractionPriceViewColors {
        FractionPriceViewColors(
            containerColor: UIColor(containerColor),
            textColor: UIColor(textColor),
            labelColor: UIColor(labelColor),
            helperColor: UIColor(helperColor),
            errorColor: UIColor(errorColor),
            buttonContainerColor: UIColor(buttonContainerColor),
            buttonIconColor: UIColor(buttonIconColor),
            unfocusedBorderColor: UIColor(unfocusedBorderColor),
            focusedBorderColor: UIColor(focusedBorderColor),
            errorBorderColor: UIColor(errorBorderColor)
        )
    }
    
    private var currentValidationResult: PriceValidationResult {
        activeRule.validatePrice(price, localization: activeLocalization)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - 1. Hero Preview UIKit Component
                VStack(alignment: .leading, spacing: 8) {
                    Text(language.previewTitleUIKit)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    FractionPriceViewRepresentable(
                        price: $price,
                        rule: activeRule,
                        localization: activeLocalization,
                        colors: activeColors,
                        labelText: labelText.isEmpty ? nil : labelText,
                        prefixText: prefixText.isEmpty ? nil : prefixText,
                        suffixText: suffixText.isEmpty ? nil : suffixText,
                        helperText: helperText.isEmpty ? nil : helperText,
                        cornerRadius: CGFloat(cornerRadius),
                        buttonCornerRadius: CGFloat(buttonCornerRadius),
                        isEnabled: isEnabled,
                        isReadOnly: isReadOnly,
                        autoCorrection: autoCorrection,
                        autoCorrectionDelayMs: UInt64(autoCorrectionDelayMs),
                        snapOnBlur: snapOnBlur,
                        labelAlignment: labelAlignment,
                        textAlignment: textAlignment,
                        onSubmitted: { submitted in
                            lastEvent = "UIKit onSubmitted(\(String(describing: submitted)))"
                        }
                    )
                    .id(language.id)
                    .frame(minHeight: 85)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
                                : UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
                        }))
                )
                
                // MARK: - Live State Inspector
                StateInspectorCard(
                    rawPrice: price,
                    formattedPrice: price != nil ? activeRule.formatPrice(price!, locale: activeLocalization.locale) : "",
                    tickStep: price != nil ? activeRule.getTickSize(for: price!) : nil,
                    validationResult: currentValidationResult,
                    lastEvent: lastEvent
                )
                
                // MARK: - Section 1: Functional Settings
                CollapsibleSection(
                    icon: "slider.horizontal.3",
                    title: language.section1Title,
                    subtitle: language.section1Subtitle,
                    isExpanded: $isFunctionalExpanded
                ) {
                    Toggle(language.toggleEnabled, isOn: $isEnabled)
                    Toggle(language.toggleReadOnly, isOn: $isReadOnly)
                    Toggle(language.toggleAutoCorrection, isOn: $autoCorrection)
                    
                    if autoCorrection {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(language.labelDebounceDelay)
                                    .font(.system(size: 13))
                                Spacer()
                                Text("\(Int(autoCorrectionDelayMs)) ms")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            Slider(value: $autoCorrectionDelayMs, in: 100...1000, step: 50)
                        }
                    }
                    
                    Toggle(language.toggleSnapOnBlur, isOn: $snapOnBlur)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(language.labelCardCornerRadius)
                                .font(.system(size: 13))
                            Spacer()
                            Text("\(Int(cornerRadius)) pt")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Slider(value: $cornerRadius, in: 0...24, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(language.labelButtonCornerRadius)
                                .font(.system(size: 13))
                            Spacer()
                            Text("\(Int(buttonCornerRadius)) pt")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Slider(value: $buttonCornerRadius, in: 0...16, step: 1)
                    }
                }
                
                // MARK: - Section 2: Component Colors (10 Tokens)
                CollapsibleSection(
                    icon: "paintpalette.fill",
                    title: language.section2Title,
                    subtitle: language.section2Subtitle,
                    isExpanded: $isColorsExpanded
                ) {
                    ColorPickerRow(title: "Container Color", description: "Input card background fill", color: $containerColor, defaultColor: Color(defaultColors.containerColor))
                    ColorPickerRow(title: "Text Color", description: "Numeric price digits color", color: $textColor, defaultColor: Color(defaultColors.textColor))
                    ColorPickerRow(title: "Label Color", description: "Title header label text", color: $labelColor, defaultColor: Color(defaultColors.labelColor))
                    ColorPickerRow(title: "Helper Color", description: "Prefix, suffix & tick info text", color: $helperColor, defaultColor: Color(defaultColors.helperColor))
                    ColorPickerRow(title: "Error Color", description: "Validation error message text", color: $errorColor, defaultColor: Color(defaultColors.errorColor))
                    ColorPickerRow(title: "Button Container Color", description: "Background of + and - buttons", color: $buttonContainerColor, defaultColor: Color(defaultColors.buttonContainerColor))
                    ColorPickerRow(title: "Button Icon Color", description: "Icon tint of + and - buttons", color: $buttonIconColor, defaultColor: Color(defaultColors.buttonIconColor))
                    ColorPickerRow(title: "Unfocused Border Color", description: "Border stroke in idle state", color: $unfocusedBorderColor, defaultColor: Color(defaultColors.unfocusedBorderColor))
                    ColorPickerRow(title: "Focused Border Color", description: "Border stroke when input is focused", color: $focusedBorderColor, defaultColor: Color(defaultColors.focusedBorderColor))
                    ColorPickerRow(title: "Error Border Color", description: "Border stroke on invalid price", color: $errorBorderColor, defaultColor: Color(defaultColors.errorBorderColor))
                }
                
                // MARK: - Section 3: Labels & Alignment
                CollapsibleSection(
                    icon: "text.aligncenter",
                    title: language.section3Title,
                    subtitle: language.section3Subtitle,
                    isExpanded: $isLabelsExpanded
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Header Label Text")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Label text", text: $labelText)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Label Alignment")
                            .font(.system(size: 13, weight: .medium))
                        Picker("Label Alignment", selection: $labelAlignment) {
                            Text("Left").tag(NSTextAlignment.left)
                            Text("Center").tag(NSTextAlignment.center)
                            Text("Right").tag(NSTextAlignment.right)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Price Text Alignment")
                            .font(.system(size: 13, weight: .medium))
                        Picker("Price Text Alignment", selection: $textAlignment) {
                            Text("Left").tag(NSTextAlignment.left)
                            Text("Center").tag(NSTextAlignment.center)
                            Text("Right").tag(NSTextAlignment.right)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prefix Text")
                                .font(.system(size: 13, weight: .medium))
                            TextField("Prefix", text: $prefixText)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suffix Text")
                                .font(.system(size: 13, weight: .medium))
                            TextField("Suffix", text: $suffixText)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Helper Text (Optional)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Leave empty for auto tick info", text: $helperText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // MARK: - Section 4: Localization & Error Handlers
                CollapsibleSection(
                    icon: "globe",
                    title: language.section4Title,
                    subtitle: language.section4Subtitle,
                    isExpanded: $isLocalizationExpanded
                ) {
                    Toggle(language.toggleCustomErrors, isOn: $useCustomErrors)
                    
                    if useCustomErrors {
                        VStack(alignment: .leading, spacing: 8) {
                            CustomErrorField(title: "Empty Price Error Template", text: $customEmptyError)
                            CustomErrorField(title: "Below Min Error Template", text: $customBelowMinError)
                            CustomErrorField(title: "Above Max Error Template", text: $customAboveMaxError)
                            CustomErrorField(title: "Invalid Tick Error Template", text: $customInvalidTickError)
                        }
                    }
                }
            }
            .padding(16)
        }
        .onAppear {
            syncLanguageDefaults(for: language)
        }
        .onChange(of: language) { newLang in
            syncLanguageDefaults(for: newLang)
        }
    }
    
    private func syncLanguageDefaults(for lang: AppLanguage) {
        labelText = "\(lang.defaultLabelText)"
        prefixText = lang.defaultPrefixText
        suffixText = lang.defaultSuffixText
        helperText = lang.defaultHelperText
        customEmptyError = lang.defaultEmptyError
        customBelowMinError = lang.defaultBelowMinError
        customAboveMaxError = lang.defaultAboveMaxError
        customInvalidTickError = lang.defaultInvalidTickError
    }
}

// MARK: - UIViewRepresentable Wrapper for FractionPriceView

private struct FractionPriceViewRepresentable: UIViewRepresentable {
    @Binding var price: Double?
    let rule: TickRule
    let localization: FractionPriceLocalization
    let colors: FractionPriceViewColors
    let labelText: String?
    let prefixText: String?
    let suffixText: String?
    let helperText: String?
    let cornerRadius: CGFloat
    let buttonCornerRadius: CGFloat
    let isEnabled: Bool
    let isReadOnly: Bool
    let autoCorrection: Bool
    let autoCorrectionDelayMs: UInt64
    let snapOnBlur: Bool
    let labelAlignment: NSTextAlignment
    let textAlignment: NSTextAlignment
    let onSubmitted: ((Double?) -> Void)?
    
    func makeUIView(context: Context) -> FractionPriceView {
        let view = FractionPriceView()
        view.rule = rule
        view.localization = localization
        view.colors = colors
        view.labelText = labelText
        view.prefixText = prefixText
        view.suffixText = suffixText
        view.helperText = helperText
        view.cornerRadius = cornerRadius
        view.buttonCornerRadius = buttonCornerRadius
        view.isEnabled = isEnabled
        view.isReadOnly = isReadOnly
        view.autoCorrection = autoCorrection
        view.autoCorrectionDelayMs = autoCorrectionDelayMs
        view.snapOnBlur = snapOnBlur
        view.labelAlignment = labelAlignment
        view.textAlignment = textAlignment
        view.setPrice(price)
        
        view.onPriceChanged = { newPrice in
            DispatchQueue.main.async {
                self.price = newPrice
            }
        }
        
        view.onSubmitted = onSubmitted
        return view
    }
    
    func updateUIView(_ uiView: FractionPriceView, context: Context) {
        uiView.rule = rule
        uiView.localization = localization
        uiView.colors = colors
        uiView.labelText = labelText
        uiView.prefixText = prefixText
        uiView.suffixText = suffixText
        uiView.helperText = helperText
        uiView.cornerRadius = cornerRadius
        uiView.buttonCornerRadius = buttonCornerRadius
        uiView.isEnabled = isEnabled
        uiView.isReadOnly = isReadOnly
        uiView.autoCorrection = autoCorrection
        uiView.autoCorrectionDelayMs = autoCorrectionDelayMs
        uiView.snapOnBlur = snapOnBlur
        uiView.labelAlignment = labelAlignment
        uiView.textAlignment = textAlignment
        uiView.onSubmitted = onSubmitted
        
        if let p = price, !uiView.textField.isFirstResponder {
            uiView.setPrice(p, updateText: true, snap: false)
        } else if price == nil {
            uiView.setPrice(nil, updateText: true, snap: false)
        }
    }
}

private struct CustomErrorField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
        }
    }
}
