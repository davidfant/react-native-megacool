require 'json'
version = JSON.parse(File.read('../package.json'))["version"]

Pod::Spec.new do |s|
  s.name         = "RNMegacool"
  s.version      = version
  s.summary      = "RNMegacool"
  s.description  = <<-DESC
                  RNMegacool
                   DESC
  s.homepage     = "http://fant.io"
  s.license      = "MIT"
  s.author             = { "author" => "david@fant.io" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/davidfant/react-native-megacool.git", :tag => "master" }
  s.source_files  = "RNMegacool/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
end

  