#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sortable_wrap.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sortable_wrap'
  s.version          = '1.0.0'
  s.summary          = 'flutter_sortable_wrap'
  s.description      = <<-DESC
Flutter keyboard visibility
                       DESC
  s.homepage         = 'https://github.com/isaacselement/flutter_sortable_wrap'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Isaacs' => 'isaacselement@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
