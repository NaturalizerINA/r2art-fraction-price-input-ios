#if canImport(UIKit)
import UIKit
import FractionPriceCore

/// Traditional UIKit UIView / UIControl component for fractional stock tick price input.
@IBDesignable
public class FractionPriceView: UIView, UITextFieldDelegate {
    
    // MARK: - Public Properties
    
    public weak var delegate: FractionPriceViewDelegate?
    
    public var rule: TickRule = TieredTickRule.idx() {
        didSet { revalidate() }
    }
    
    public var localization: FractionPriceLocalization = .id {
        didSet {
            if let p = price, !textField.isFirstResponder {
                textField.text = rule.formatPrice(p, locale: effectiveLocalization.locale)
            }
            revalidate()
        }
    }
    
    public var colors: FractionPriceViewColors = .default {
        didSet { applyColors() }
    }
    
    public var onPriceChanged: ((Double?) -> Void)?
    public var onSubmitted: ((Double?) -> Void)?
    public var onValidationChanged: ((PriceValidationResult) -> Void)?
    
    public var emptyPriceError: (() -> String)?
    public var belowMinError: ((String) -> String)?
    public var aboveMaxError: ((String) -> String)?
    public var invalidTickError: ((String, String) -> String)?
    
    @IBInspectable public var labelText: String? {
        didSet {
            titleLabel.text = labelText
            titleLabel.isHidden = labelText == nil || labelText?.isEmpty == true
        }
    }
    
    @IBInspectable public var prefixText: String? {
        didSet {
            prefixLabel.text = prefixText
            prefixLabel.isHidden = prefixText == nil || prefixText?.isEmpty == true
        }
    }
    
    @IBInspectable public var suffixText: String? {
        didSet {
            suffixLabel.text = suffixText
            suffixLabel.isHidden = suffixText == nil || suffixText?.isEmpty == true
        }
    }
    
    @IBInspectable public var helperText: String? {
        didSet { updateFooterText() }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 10 {
        didSet {
            containerView.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var buttonCornerRadius: CGFloat = 8 {
        didSet {
            minusButton.layer.cornerRadius = buttonCornerRadius
            plusButton.layer.cornerRadius = buttonCornerRadius
        }
    }
    
    @IBInspectable public var autoCorrection: Bool = false
    @IBInspectable public var autoCorrectionDelayMs: UInt64 = 300
    @IBInspectable public var snapOnBlur: Bool = true
    @IBInspectable public var isReadOnly: Bool = false {
        didSet {
            textField.isUserInteractionEnabled = !isReadOnly && isEnabled
            minusButton.isEnabled = !isReadOnly && isEnabled
            plusButton.isEnabled = !isReadOnly && isEnabled
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            textField.isEnabled = isEnabled && !isReadOnly
            minusButton.isEnabled = isEnabled && !isReadOnly
            plusButton.isEnabled = isEnabled && !isReadOnly
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public var labelAlignment: NSTextAlignment = .left {
        didSet { titleLabel.textAlignment = labelAlignment }
    }
    
    public var textAlignment: NSTextAlignment = .center {
        didSet { textField.textAlignment = textAlignment }
    }
    
    public private(set) var price: Double?
    public private(set) var currentValidationResult: PriceValidationResult = .empty()
    
    // MARK: - UI Elements
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let contentStack = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let prefixLabel = InsetsLabel(insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 6))
    public let textField = InsetsTextField(insets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
    private let suffixLabel = InsetsLabel(insets: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 12))
    private let plusButton = UIButton(type: .system)
    private let footerLabel = UILabel()
    
    // MARK: - Gesture & Concurrency Variables
    
    private var isMinusPressing = false
    private var isPlusPressing = false
    private var stepperTask: Task<Void, Never>?
    private var autoCorrectTask: Task<Void, Never>?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views & Layout
    
    private func setupViews() {
        // Vertical Root Stack
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 1. Title Label
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.isHidden = true
        stackView.addArrangedSubview(titleLabel)
        
        // 2. Container Card View
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = cornerRadius
        stackView.addArrangedSubview(containerView)
        
        // Content Horizontal Stack
        contentStack.axis = .horizontal
        contentStack.alignment = .fill
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            contentStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Minus Button
        setupButton(minusButton, systemName: "minus")
        minusButton.addTarget(self, action: #selector(minusTouchDown), for: .touchDown)
        minusButton.addTarget(self, action: #selector(minusTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Prefix Label
        prefixLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        prefixLabel.isHidden = true
        prefixLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Text Field
        textField.font = .systemFont(ofSize: 18, weight: .bold)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Suffix Label
        suffixLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        suffixLabel.isHidden = true
        suffixLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Plus Button
        setupButton(plusButton, systemName: "plus")
        plusButton.addTarget(self, action: #selector(plusTouchDown), for: .touchDown)
        plusButton.addTarget(self, action: #selector(plusTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        contentStack.addArrangedSubview(minusButton)
        contentStack.addArrangedSubview(prefixLabel)
        contentStack.addArrangedSubview(textField)
        contentStack.addArrangedSubview(suffixLabel)
        contentStack.addArrangedSubview(plusButton)
        
        NSLayoutConstraint.activate([
            minusButton.widthAnchor.constraint(equalToConstant: 44),
            minusButton.heightAnchor.constraint(equalToConstant: 44),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 3. Footer Label
        footerLabel.font = .systemFont(ofSize: 12, weight: .regular)
        footerLabel.numberOfLines = 0
        stackView.addArrangedSubview(footerLabel)
        
        applyColors()
        revalidate()
    }
    
    private func setupButton(_ button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.masksToBounds = true
    }
    
    // MARK: - Color Styling
    
    public func applyColors() {
        containerView.backgroundColor = colors.containerColor
        textField.textColor = colors.textColor
        titleLabel.textColor = colors.labelColor
        prefixLabel.textColor = colors.helperColor
        suffixLabel.textColor = colors.helperColor
        
        minusButton.backgroundColor = colors.buttonContainerColor
        minusButton.tintColor = colors.buttonIconColor
        plusButton.backgroundColor = colors.buttonContainerColor
        plusButton.tintColor = colors.buttonIconColor
        
        updateBorderAndFooter()
    }
    
    private func updateBorderAndFooter() {
        if !currentValidationResult.isValid {
            containerView.layer.borderColor = colors.errorBorderColor.cgColor
            containerView.layer.borderWidth = 1.5
            footerLabel.textColor = colors.errorColor
        } else if textField.isFirstResponder {
            containerView.layer.borderColor = colors.focusedBorderColor.cgColor
            containerView.layer.borderWidth = 1.5
            footerLabel.textColor = colors.helperColor
        } else {
            containerView.layer.borderColor = colors.unfocusedBorderColor.cgColor
            containerView.layer.borderWidth = 1.0
            footerLabel.textColor = colors.helperColor
        }
        
        updateFooterText()
    }
    
    private func updateFooterText() {
        if !currentValidationResult.isValid, let error = currentValidationResult.errorMessage {
            footerLabel.text = error
            footerLabel.isHidden = false
        } else if let helper = helperText, !helper.isEmpty {
            footerLabel.text = helper
            footerLabel.isHidden = false
        } else if let p = price, let step = currentValidationResult.currentStep ?? Optional(rule.getTickSize(for: p)) {
            let formattedStep = rule.formatPrice(step, locale: effectiveLocalization.locale, currencySymbol: effectiveLocalization.currencySymbol)
            footerLabel.text = "\(effectiveLocalization.labelText): \(formattedStep)"
            footerLabel.isHidden = false
        } else {
            footerLabel.text = nil
            footerLabel.isHidden = true
        }
    }
    
    private var effectiveLocalization: FractionPriceLocalization {
        localization.copyWith(
            emptyPriceError: emptyPriceError,
            belowMinError: belowMinError,
            aboveMaxError: aboveMaxError,
            invalidTickError: invalidTickError
        )
    }
    
    // MARK: - Public State Mutators
    
    public func setPrice(_ newPrice: Double?, updateText: Bool = true, snap: Bool = false) {
        let finalPrice = (snap && newPrice != nil) ? rule.snapToTick(price: newPrice!, mode: .nearest) : newPrice
        self.price = finalPrice
        
        if updateText {
            if let p = finalPrice {
                textField.text = rule.formatPrice(p, locale: effectiveLocalization.locale)
            } else {
                textField.text = ""
            }
        }
        
        revalidate()
        onPriceChanged?(finalPrice)
        delegate?.fractionPriceView(self, didChangePrice: finalPrice)
    }
    
    public func stepUp(ticks: Int = 1) {
        autoCorrectTask?.cancel()
        let base = price ?? rule.minPrice ?? 0.0
        let next = rule.nextTick(price: base, ticks: ticks)
        setPrice(next, updateText: true, snap: false)
    }
    
    public func stepDown(ticks: Int = 1) {
        autoCorrectTask?.cancel()
        let base = price ?? rule.minPrice ?? 0.0
        let prev = rule.prevTick(price: base, ticks: ticks)
        setPrice(prev, updateText: true, snap: false)
    }
    
    public func snap(mode: RoundingMode = .nearest) {
        guard let p = price else { return }
        let snapped = rule.snapToTick(price: p, mode: mode)
        setPrice(snapped, updateText: true, snap: false)
    }
    
    public func revalidate() {
        self.currentValidationResult = rule.validatePrice(price, localization: effectiveLocalization)
        updateBorderAndFooter()\
        onValidationChanged?(currentValidationResult)
        delegate?.fractionPriceView(self, didValidate: currentValidationResult)
    }
    
    // MARK: - Text Field & Stepper Actions
    
    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        let parsed = rule.parsePrice(text, locale: effectiveLocalization.locale)
        self.price = parsed
        
        revalidate()
        onPriceChanged?(parsed)
        delegate?.fractionPriceView(self, didChangePrice: parsed)
        
        if autoCorrection, let p = parsed, !rule.isValidTick(price: p) {
            autoCorrectTask?.cancel()
            autoCorrectTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: autoCorrectionDelayMs * 1_000_000)
                guard !Task.isCancelled else { return }
                let snapped = self.rule.snapToTick(price: p, mode: .nearest)
                self.setPrice(snapped, updateText: true, snap: false)
            }
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBorderAndFooter()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        autoCorrectTask?.cancel()
        if snapOnBlur, let p = price {
            let snapped = rule.snapToTick(price: p, mode: .nearest)
            setPrice(snapped, updateText: true, snap: false)
        } else if let p = price {
            textField.text = rule.formatPrice(p, locale: effectiveLocalization.locale)
        }
        updateBorderAndFooter()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onSubmitted?(price)
        delegate?.fractionPriceView(self, didSubmitPrice: price)
        return true
    }
    
    // MARK: - Stepper Continuous Press Gestures
    
    @objc private func minusTouchDown() {
        guard isEnabled && !isReadOnly else { return }
        isMinusPressing = true
        stepDown(ticks: 1)
        feedbackGenerator.impactOccurred()
        startContinuousStepper(isPlus: false)
    }
    
    @objc private func minusTouchUp() {
        isMinusPressing = false
        stopContinuousStepper()
    }
    
    @objc private func plusTouchDown() {
        guard isEnabled && !isReadOnly else { return }
        isPlusPressing = true
        stepUp(ticks: 1)
        feedbackGenerator.impactOccurred()
        startContinuousStepper(isPlus: true)
    }
    
    @objc private func plusTouchUp() {
        isPlusPressing = false
        stopContinuousStepper()
    }
    
    private func startContinuousStepper(isPlus: Bool) {
        stepperTask?.cancel()
        stepperTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            var intervalMs: UInt64 = 160
            let minIntervalMs: UInt64 = 40
            let reductionMs: UInt64 = 15
            
            while !Task.isCancelled && (isPlus ? isPlusPressing : isMinusPressing) {
                if isPlus {
                    stepUp(ticks: 1)
                } else {
                    stepDown(ticks: 1)
                }
                feedbackGenerator.impactOccurred()
                
                try? await Task.sleep(nanoseconds: intervalMs * 1_000_000)
                if intervalMs > minIntervalMs + reductionMs {
                    intervalMs -= reductionMs
                } else {
                    intervalMs = minIntervalMs
                }
            }
        }
    }
    
    private func stopContinuousStepper() {
        stepperTask?.cancel()
        stepperTask = nil
    }
}

// MARK: - Insets Helper Views

private class InsetsLabel: UILabel {
    var insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.insets = .zero
        super.init(coder: coder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}

public class InsetsTextField: UITextField {
    public var insets: UIEdgeInsets
    
    public init(insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        self.insets = .zero
        super.init(coder: coder)
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}
#endif
