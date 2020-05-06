using_local_pods = ENV['USE_LOCAL_PODS'] == 'true' || false

platform :ios, '12.0'

if using_local_pods
  # Pull pods from sibling directories if using local pods
  target 'ArisenSwiftAbirixSerializationProvider' do
    use_frameworks!

    pod 'ArisenSwift', :path => '../arisen-swift'
    pod 'SwiftLint'

    target 'ArisenSwiftAbirixTests' do
      inherit! :search_paths
      pod 'ArisenSwift', :path => '../arisen-swift'
    end
  end
else
  # Pull pods from sources above if not using local pods
  target 'ArisenSwiftAbirixSerializationProvider' do
    use_frameworks!

    pod 'ArisenSwift', '~> 0.2.1'
    pod 'SwiftLint'

    target 'ArisenSwiftAbirixTests' do
      inherit! :search_paths
      pod 'ArisenSwift', '~> 0.2.1'
    end
  end
end
