#
# Be sure to run `pod lib lint SZWebViewBridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'SZWebViewBridge'
    s.version          = '1.0.0'
    s.summary          = 'SZWebViewBridge is a lightweight, pure-Swift library for bridge sending messages between WKWebView and Web client. Based on message handler.'

    s.homepage         = 'https://github.com/eroscai/SZWebViewBridge'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'eroscai' => 'csz0102@gmail.com' }
    s.source           = { :git => 'https://github.com/eroscai/SZWebViewBridge.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'
    s.swift_version = "5.0"

    s.source_files = 'SZWebViewBridge/Classes/**/*'

    s.resource_bundles = {
        'SZWebViewBridge' => ['SZWebViewBridge/Assets/**/*.js', 'SZWebViewBridge/Assets/**/*.jpg']
    }

    s.frameworks = 'UIKit', 'WebKit'
end
