#
# Be sure to run `pod lib lint IQChannelsSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IQChannelsSwift'
  s.version          = '1.0.0'
  s.summary          = 'IQChannelsSwift SDK'
  s.description      = <<-DESC
IQChannelsSwift iOS SDK
                       DESC

  s.homepage         = 'https://github.com/dato3/iqchannels-swift-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daulet Tokmukhanbet' => '61043918+dato3@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/dato3/iqchannels-swift-sdk.git', :tag => s.version.to_s }

  s.platform = :ios, '14.0'
  s.ios.deployment_target = '14.0'

  s.source_files = 'IQChannelsSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IQChannelsSwift' => ['IQChannelsSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'SDWebImage', '~>5.10'
  s.dependency 'TRVSEventSource', '0.0.8'
  s.dependency 'MessageKit', '3.1.1'
  s.dependency 'SnapKit', '5.6.0'
   
end
