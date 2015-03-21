
Pod::Spec.new do |s|
  s.name         = "Instagramer"
  s.version      = "0.0.1"
  s.summary      = "Instagram API Wrapper"

  s.description  = <<-DESC
                   Instagramer API Wrapper (swift)
                   DESC

  s.homepage     = "https://github.com/gitobi/Instagramer.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "TakuroOnoda" => "takuro.onoda@gitobi.com" }
  s.ios.deployment_target = "7.0"
  # s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/gitobi/Instagramer.git" }
  #s.source       = { :git => "https://github.com/gitobi/Instagramer.git", :tag => "0.0.1" }
  #s.source       = { :git => "https://github.com/gitobi/Instagramer.git", :branch => "podded" }

  s.source_files  = "Instagramer", "Instagramer/**/*.{swift,h,m}"
  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
#  s.resources = "Instagramer/Resources/**/*.*"
  s.resources = "Resources.bundle"
#  s.resource_bundle = {'com_gitobi_Instagramer' => ["Instagramer.bundle/*"]}

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.requires_arc = true

  s.dependency "Alamofire"
  s.dependency "SwiftyJSON"

end

