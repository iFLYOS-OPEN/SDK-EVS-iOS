Pod::Spec.new do |s|
s.name        = "SDK-EVS-iOS"
s.version     = "1.1.1"
s.authors     = { "jwzhou2" => "jwzhou2@iflytek.com" }
s.homepage    = "https://github.com/iFLYOS-OPEN/SDK-EVS-iOS"
s.summary     = "SDK-EVS-iOS."
s.source      = { :git => "https://github.com/iFLYOS-OPEN/SDK-EVS-iOS.git",:tag => s.version}
s.license     = { :type => "MIT", :file => "LICENSE" }

s.source_files  = "Pod/Classes/**/*.{h,m,mm}"
s.frameworks = 'UIKit', 'Foundation' , 'Security','CoreLocation'

s.dependency 'PLPlayerKit', '~> 3.4.3'
s.dependency 'FreeStreamer'
s.dependency 'opus-ios'
s.dependency 'Protobuf'
s.dependency 'FMDB'
s.dependency 'SocketRocket'
s.dependency 'MJExtension'
s.dependency 'AFNetworking', '~> 3.2.1'
s.dependency 'WebViewJavascriptBridge'
s.dependency 'KeychainItemWrapper-Copy'

s.pod_target_xcconfig = {
'ONLY_ACTIVE_ARCH' => 'YES',
'OTHER_LDFLAGS' => ['-ObjC'] ,
'ENABLE_BITCODE' => 'NO'
}

s.ios.deployment_target = '10.1'

end
