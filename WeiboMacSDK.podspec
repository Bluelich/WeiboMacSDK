Pod::Spec.new do |s|
  s.name             = "WeiboMacSDK"
  s.version          = "3.0.0"
  s.summary          = "Weibo SDK for Mac."
  s.description      = <<-DESC
                        Weibo SDK for Mac applications.
                       DESC
  s.homepage         = "https://github.com/Naituw/WeiboMacSDK"
  s.license          = 'MIT'
  s.author           = { "Wutian" => "naituw@gmail.com" }
  s.source           = { :git => "https://github.com/Naituw/WeiboMacSDK.git", :tag => '3.0.0' }
  s.social_media_url = 'http://weibo.com/naituw'

  s.platform     = :osx
  s.osx.deployment_target = '10.8'

  s.prefix_header_file = "WeiboSDK/SupportingFiles/WeiboSDK-Prefix.pch"
  s.source_files = 'WeiboSDK/**/*.{h,m,c}'
  s.requires_arc = true,
  s.resources = 'WeiboSDKResources'

  s.dependency 'libextobjc'
  s.dependency 'JSONKit-NoWarning', '~> 1.1'
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'FMDB', '~> 2.2'
  s.dependency 'RegexKitLite'
  s.dependency 'AFNetworking'
  s.dependency 'CocoaSecurity', '~> 1.2'
  s.dependency 'NSDictionary+Accessors', :git => 'https://github.com/Naituw/NSDictionary-Accessors.git'

end
