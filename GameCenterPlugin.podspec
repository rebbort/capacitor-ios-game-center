Pod::Spec.new do |s|
  s.name = 'GameCenterPlugin'
  s.version = '1.0.0'
  s.summary = 'Game Center plugin'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/yourorg/capacitor-ios-game-center'
  s.author = { 'Author' => 'dev@example.com' }
  s.source = { :git => 'https://github.com/yourorg/capacitor-ios-game-center.git', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,mm}'
  s.dependency 'Capacitor'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
end
