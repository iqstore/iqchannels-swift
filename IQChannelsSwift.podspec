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

  s.subspec 'Additional' do |spec|
    spec.source_files = 'IQChannelsSwift/Additional/**/*'
  end
  
  s.subspec 'Calculators' do |spec|
    spec.source_files = 'IQChannelsSwift/Calculators/**/*'
  end
  
  s.subspec 'Cells' do |spec|
    spec.source_files = 'IQChannelsSwift/Cells/**/*'
  end
  
  s.subspec 'Extensions' do |spec|
    spec.source_files = 'IQChannelsSwift/Extensions/**/*'
  end
  
  s.subspec 'Models' do |spec|
    spec.source_files = 'IQChannelsSwift/Models/**/*'
  end
  
  s.subspec 'Networking' do |spec|
    spec.source_files = 'IQChannelsSwift/Networking/**/*'
  end
  
  s.subspec 'Protocols' do |spec|
    spec.source_files = 'IQChannelsSwift/Protocols/**/*'
  end
  
  s.subspec 'Views' do |spec|
    spec.source_files = 'IQChannelsSwift/Views/**/*'
  end
  
  s.resource_bundles = {
      'IQChannelsSwift' => ['IQChannelsSwift/Assets/Assets.xcassets']
  }
  
  s.dependency 'SDWebImage', '~>5.10'
  s.dependency 'TRVSEventSource', '0.0.8'
  s.dependency 'MessageKit', '3.1.1'
  s.dependency 'SnapKit', '5.6.0'
  s.dependency 'SwiftMessages', '9.0.9'
   
end
