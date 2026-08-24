Pod::Spec.new do |s|
  s.name             = 'R2ArtFractionPriceInput'
  s.version          = '1.0.0'
  s.summary          = 'Industry-standard fraction tick price input component for iOS Native (SwiftUI & UIKit) compliant with IDX / BEI rules.'
  s.description      = <<-DESC
An industry-grade stock fraction price input library for iOS Native (Swift).
Supports dual UI toolkits (SwiftUI and UIKit), pure Swift engine with 100% test coverage,
customizable colors and errors, press-and-hold stepper acceleration, and auto-correction.
                       DESC

  s.homepage         = 'https://github.com/NaturalizerINA/r2art-fraction-price-input-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rahmad Setiawan Mukminullah' => 'rahmad.setiawan@example.com' }
  s.source           = { :git => 'https://github.com/NaturalizerINA/r2art-fraction-price-input-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '15.0'
  s.swift_versions        = ['5.9', '5.10', '6.0']

  s.default_subspec = 'All'

  s.subspec 'All' do |all|
    all.dependency 'R2ArtFractionPriceInput/Core'
    all.dependency 'R2ArtFractionPriceInput/SwiftUI'
    all.dependency 'R2ArtFractionPriceInput/UIKit'
  end

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/FractionPriceCore/**/*.swift'
    core.frameworks   = 'Foundation', 'Combine'
  end

  s.subspec 'SwiftUI' do |swiftui|
    swiftui.source_files = 'Sources/FractionPriceSwiftUI/**/*.swift'
    swiftui.dependency 'R2ArtFractionPriceInput/Core'
    swiftui.frameworks   = 'SwiftUI', 'UIKit'
  end

  s.subspec 'UIKit' do |uikit|
    uikit.source_files = 'Sources/FractionPriceUIKit/**/*.swift'
    uikit.dependency 'R2ArtFractionPriceInput/Core'
    uikit.frameworks   = 'UIKit'
  end
end
