Pod::Spec.new do |s|
  s.name             = 'R2ArtFractionPriceInput'
  s.version          = '1.0.0'
  s.summary          = 'An industry-grade stock fraction tick price input component for iOS (SwiftUI & UIKit) compliant with BEI/IDX.'

  s.description      = <<-DESC
    R2Art Fraction Price Input is a comprehensive, production-ready iOS library for stock trading apps.
    It provides 100% UI and functional parity between SwiftUI and UIKit, implementing official Indonesia
    Stock Exchange (BEI / IDX) 5-tier fraction rules, press-and-hold velocity stepping, debounce auto-correction,
    bilingual localization, and 10 granular color design tokens.
                       DESC

  s.homepage         = 'https://github.com/NaturalizerINA/r2art-fraction-price-input-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rahmad Setiawan Mukminullah' => 'rahmad.mukminullah@gmail.com' }
  s.source           = { :git => 'https://github.com/NaturalizerINA/r2art-fraction-price-input-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']

  s.default_subspec = 'All'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/FractionPriceCore/**/*'
  end

  s.subspec 'SwiftUI' do |sw|
    sw.source_files = 'Sources/FractionPriceSwiftUI/**/*'
    sw.dependency 'R2ArtFractionPriceInput/Core'
    sw.frameworks = 'SwiftUI'
  end

  s.subspec 'UIKit' do |uk|
    uk.source_files = 'Sources/FractionPriceUIKit/**/*'
    uk.dependency 'R2ArtFractionPriceInput/Core'
    uk.frameworks = 'UIKit'
  end

  s.subspec 'All' do |all|
    all.dependency 'R2ArtFractionPriceInput/Core'
    all.dependency 'R2ArtFractionPriceInput/SwiftUI'
    all.dependency 'R2ArtFractionPriceInput/UIKit'
  end
end
