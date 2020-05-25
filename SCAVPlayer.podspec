Pod::Spec.new do |s|
  s.name             = 'SCAVPlayer'
  s.version          = '1.0.3'
  s.summary          = 'SCAVPlayer.'
  s.homepage         = 'https://github.com/Samueler/SCAVPlayer.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ty.Chen' => 'chenty@mama.cn' }
  s.source           = { :git => 'https://github.com/Samueler/SCAVPlayer.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SCAVPlayer/Classes/**/*.{h,m}'
  
  s.dependency 'KVOController', '1.2.0'
  
end
