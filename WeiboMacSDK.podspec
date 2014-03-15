Pod::Spec.new do |s|
  s.name             = "WeiboMacSDK"
  s.version          = "0.1.0"
  s.summary          = "Weibo SDK for Mac."
  s.description      = <<-DESC
                        Weibo SDK for Mac applications.
                       DESC
  s.homepage         = "https://github.com/Naituw/WeiboMacSDK"
  s.license          = 'MIT'
  s.author           = { "Wutian" => "naituw@gmail.com" }
  s.source           = { :git => "https://github.com/Naituw/WeiboMacSDK.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/naituw'

  s.platform     = :osx
  s.osx.deployment_target = '10.7'

  s.subspec 'Vendors' do |sp|
    sp.source_files = 'WeiboSDK/Vendors/**/*.{h,m,c}'
    sp.requires_arc = false
    sp.compiler_flags = '-fno-objc-arc'
  end

  s.subspec 'Classes' do |sp|
    sp.prefix_header_file = "WeiboSDK/SupportingFiles/WeiboSDK-Prefix.pch"
    sp.source_files = 'WeiboSDK/**/*.{h,m,c}'
    sp.requires_arc = true,
    sp.exclude_files = 'WeiboSDK/Vendors/**/*.{h,m,c}'
    sp.dependency 'WeiboMacSDK/Vendors'
  end

  s.resources = 'WeiboSDKResources'

  s.dependency 'libextobjc'
  s.dependency 'JSONKit-NoWarning', '~> 1.1'
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'FMDB', '~> 2.2'
  s.dependency 'RegexKitLite'

end
