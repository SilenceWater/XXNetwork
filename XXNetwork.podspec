
Pod::Spec.new do |s|
  s.name             = 'XXNetwork'
  s.version          = '0.1.0'
  s.summary          = 'A short description of XXNetwork.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Monster ./XXNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Monster .' => 'wwwarehouse@163.com' }
  s.source           = { :git => 'https://github.com/Monster ./XXNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'XXNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'XXNetwork' => ['XXNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'AFNetworking'
  
  
end
