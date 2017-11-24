#
# Be sure to run `pod lib lint iOSDFULibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "iOSDFULibrary"
  s.version          = "4.0.3"
  s.summary          = "This repository contains a tested library for iOS 8+ devices to perform Device Firmware Update on the nRF5x devices"
  s.description      = <<-DESC
The nRF5x Series chips are flash-based SoCs, and as such they represent the most flexible solution available. A key feature of the nRF5x Series and their associated software architecture and S-Series SoftDevices is the possibility for Over-The-Air Device Firmware Upgrade (OTA-DFU). See Figure 1. OTA-DFU allows firmware upgrades to be issued and downloaded to products in the field via the cloud and so enables OEMs to fix bugs and introduce new features to products that are already out on the market. This brings added security and flexibility to product development when using the nRF5x Series SoCs.
                       DESC

  s.homepage         = "https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library"
  s.license          = 'BSD 3-Clause'
  s.authors           = { "Mostafa Berg" => "mostafa.berg@nordicsemi.no", "Aleksander Nowakowski" => "aleksander.nowakowski@nordicsemi.no" }
  s.source           = { :git => "https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nordictweets'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'iOSDFULibrary/Classes/**/*'

  s.dependency 'Zip', '~> 1.0'
end
