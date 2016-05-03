Pod::Spec.new do |s|
  s.name         = "react-native-NYTPhotoViewer"
  s.version      = "1.1.5"
  s.summary      = "React native wrapper for the NYTPhotoViewer library"
  s.homepage     = "https://github.com/sprightco/react-native-NYTPhotoViewer"
  s.license      = "MIT"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/sprightco/react-native-NYTPhotoViewer" }
  s.source_files  = "ios/RCTNYTPhotoViewer/*.{h,m}"

  s.dependency 'React'
  s.dependency 'NYTPhotoViewer', '~> 1.1.0'
end
