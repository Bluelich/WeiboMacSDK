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
  s.requires_arc = true

  s.dependency 'libextobjc'
end
