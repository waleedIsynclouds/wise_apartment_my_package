#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint wise_apartment.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'wise_apartment'
  s.version          = '0.0.1'
  s.summary          = 'iOS plugin for Smart Lock SDK integration'
  s.description      = <<-DESC
Flutter plugin providing BLE device scanning, pairing, and WiFi configuration for Smart Lock devices.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Frameworks"',
    'OTHER_LDFLAGS' => '$(inherited) -framework HXJBLESDK',
  }

  # System frameworks required for BLE operations
  s.frameworks = 'CoreBluetooth', 'Foundation'
  
  # HXJ BLE SDK vendored framework (local)
  # Place HXJBLESDK.framework in the ios/Frameworks/ directory
  s.vendored_frameworks = 'Frameworks/HXJBLESDK.framework'
  
  s.swift_version = '5.0'
end
