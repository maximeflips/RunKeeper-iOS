#
# Be sure to run `pod lib lint ITBeacons.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RunKeeper-iOS"
  s.version          = "0.0.1"
  s.summary          = "RunKeeper SDK for iOS."
  s.description      = <<-DESC
                       RunKeeper SDK for iOS allows an abstraction of the API.
                       DESC
  s.homepage         = "http://bitbucket.org/iterar/runkeeper-ios.git"
  s.license          = 'MIT'
  s.author           = { "Iterar" => "team@iterar.co" }
  s.source           = { :git => "git@bitbucket.org:iterar/runkeeper-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_iterar'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'RunKeeper/Classes'
  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'NXOAuth2Client', '~> 1.2.8'
end
