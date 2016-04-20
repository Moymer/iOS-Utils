#
# Be sure to run `pod lib lint iOS-Utils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "iOS-Utils"
  s.version          = "0.1.0"
  s.summary          = "This pod has util classes for the main app"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!


s.description      =  "This pod should be used as a tool for the development of Moymer's apps"

s.homepage         = "http://www.moymer.com:8080/#en"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
s.license          = 'MIT'
s.author           = { "Moymer" => "gustavo.tiago@moymer.com" }
s.source           = { :git => "https://github.com/Moymer/iOS-Utils.git", :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/moymerapp'

  s.ios.deployment_target = '8.0'

  s.source_files = 'iOS-Utils/Classes/**/*'
  s.resource_bundles = {
    'iOS-Utils' => ['iOS-Utils/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
