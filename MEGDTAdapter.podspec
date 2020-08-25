#
# Be sure to run `pod lib lint MEGDTAdapter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MEGDTAdapter'
  s.version          = '1.0.1'
  s.summary          = 'A adapter of GDT for mediation SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "this is a Mobiexchanger's advertise adapter, and we use it as a module"

  s.homepage         = 'https://github.com/liusas/MEGDTAdapter.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '刘峰' => 'liufeng@mobiexchanger.com' }
  s.source           = { :git => 'https://github.com/liusas/MEGDTAdapter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MEGDTAdapter/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MEGDTAdapter' => ['MEGDTAdapter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency "GDTMobSDK", "~> 4.10.19"
  s.dependency "MEAdvSDK", '~> 1.0.1'
  
end
