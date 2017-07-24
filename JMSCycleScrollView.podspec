Pod::Spec.new do |s|

  s.name          = "JMSCycleScrollView"
  s.version       = "1.0.5"
  s.license       = "MIT"
  s.summary       = "A custom image reseeder using Swift."
  s.homepage      = "https://github.com/James-swift/JMSCycleScrollView"
  s.author        = { "xiaobs" => "1007785739@qq.com" }
  s.source        = { :git => "https://github.com/James-swift/JMSCycleScrollView.git", :tag => "1.0.5" }
  s.requires_arc  = true
  s.description   = <<-DESC
                   JMSCycleScrollView - A custom image reseeder using Swift.
                   DESC
  s.source_files  = "JMSCycleScrollView/Lib/*"
  s.platform      = :ios, '8.0'
  s.framework     = 'Foundation', 'UIKit'
  s.dependency "Kingfisher", "~> 3.10.3"
  s.dependency "JMSPageControl", "~> 1.0.2"

end
