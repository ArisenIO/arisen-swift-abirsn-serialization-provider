#
# Be sure to run `pod lib lint ArisenSwiftAbirixSerializationProvider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ArisenSwiftAbirixSerializationProvider'
  s.version          = '0.2.1'
  s.summary          = 'Binary <> JSON conversion using ABIs. Compatible with languages which can interface to C.'
  s.homepage         = 'https://github.com/ARISENIO/arisen-swift-abirix-serialization-provider'
  s.license          = { :type => 'MIT', :text => <<-LICENSE
                           Copyright (c) 2017-2019 block.one and its contributors.  All rights reserved.
                         LICENSE
                       }
  s.author           = { 'Todd Bowden' => 'todd.bowden@block.one',
                         'Serguei Vinnitskii' => 'serguei.vinnitskii@block.one',
                         'Farid Rahmani' => 'farid.rahmani@block.one',
                         'Brandon Fancher' => 'brandon.fancher@block.one',
                         'Mark Johnson' => 'mark.johnson@block.one',
                         'Paul Kim' => 'paul.kim@block.one',
                         'Steve McCoole' => 'steve.mccoole@objectpartners.com',
                         'Ben Martell' => 'ben.martell@objectpartners.com' }
  s.source           = { :git => 'https://github.com/ARISENIO/arisen-swift-abirix-serialization-provider.git', :tag => "v" + s.version.to_s }

  s.swift_version         = '5.0'
  s.ios.deployment_target = '12.0'

  s.public_header_files = 'ArisenSwiftAbirixSerializationProvider/ArisenSwiftAbirixSerializationProvider.h',
                          'ArisenSwiftAbirixSerializationProvider/abirix.h'

  s.source_files = 'ArisenSwiftAbirixSerializationProvider/**/*.{c,h,m,cpp,hpp}',
                   'ArisenSwiftAbirixSerializationProvider/**/*.swift'

  s.preserve_paths = 'ArisenSwiftAbirixSerializationProvider/arisen.assert.abi.json',
                     'ArisenSwiftAbirixSerializationProvider/transaction.abi.json',
                     'ArisenSwiftAbirixSerializationProvider/abi.abi.json'

  s.ios.resource_bundle = { 'ArisenSwiftAbirixSerializationProvider' => 'ArisenSwiftAbirixSerializationProvider/*.abi.json' }

  s.resources = 'ArisenSwiftAbirixSerializationProvider/transaction.abi.json',
                'ArisenSwiftAbirixSerializationProvider/abi.abi.json',
                'ArisenSwiftAbirixSerializationProvider/arisen.assert.abi.json'

  s.libraries = "c++"
  s.pod_target_xcconfig = { 'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++17',
                            'CLANG_CXX_LIBRARY' => 'libc++',
                            'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                            'CLANG_ENABLE_MODULES' => 'YES',
                            'SWIFT_COMPILATION_MODE' => 'wholemodule',
                            'ENABLE_BITCODE' => 'YES'}

  s.ios.dependency 'ArisenSwift', '~> 0.2.1'
end
