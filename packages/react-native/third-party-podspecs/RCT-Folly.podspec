# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

folly_config = get_folly_config()
folly_compiler_flags = folly_config[:compiler_flags]
folly_release_version = folly_config[:version]

Pod::Spec.new do |spec|
  spec.name = 'RCT-Folly'
  # Patched to v2 to address https://github.com/react-native-community/releases/issues/251
  spec.version = folly_release_version
  spec.license = { :type => 'Apache License, Version 2.0' }
  spec.homepage = 'https://github.com/facebook/folly'
  spec.summary = 'An open-source C++ library developed and used at Facebook.'
  spec.authors = 'Facebook'
  spec.source = { :git => 'https://github.com/react-native-tvos/folly.git',
                  :tag => "tv-v#{folly_release_version}" }
  spec.module_name = 'folly'
  spec.header_mappings_dir = '.'
  spec.dependency 'boost'
  spec.dependency 'DoubleConversion'
  spec.dependency 'glog'
  spec.dependency "fmt", "9.1.0"
  spec.compiler_flags = folly_compiler_flags
  spec.source_files = 'folly/String.cpp',
                      'folly/Conv.cpp',
                      'folly/Demangle.cpp',
                      'folly/FileUtil.cpp',
                      'folly/Format.cpp',
                      'folly/lang/SafeAssert.cpp',
                      'folly/lang/ToAscii.cpp',
                      'folly/ScopeGuard.cpp',
                      'folly/Unicode.cpp',
                      'folly/dynamic.cpp',
                      'folly/json.cpp',
                      'folly/json_pointer.cpp',
                      'folly/container/detail/F14Table.cpp',
                      'folly/detail/Demangle.cpp',
                      'folly/detail/FileUtilDetail.cpp',
                      'folly/detail/SplitStringSimd.cpp',
                      'folly/detail/UniqueInstance.cpp',
                      'folly/hash/SpookyHashV2.cpp',
                      'folly/lang/Assume.cpp',
                      'folly/lang/CString.cpp',
                      'folly/lang/Exception.cpp',
                      'folly/memory/detail/MallocImpl.cpp',
                      'folly/net/NetOps.cpp',
                      'folly/portability/SysUio.cpp',
                      'folly/synchronization/SanitizeThread.cpp',
                      'folly/system/AtFork.cpp',
                      'folly/system/ThreadId.cpp',
                      'folly/*.h',
                      'folly/container/*.h',
                      'folly/container/detail/*.h',
                      'folly/detail/*.h',
                      'folly/functional/*.h',
                      'folly/hash/*.h',
                      'folly/lang/*.h',
                      'folly/memory/*.h',
                      'folly/memory/detail/*.h',
                      'folly/net/*.h',
                      'folly/net/detail/*.h',
                      'folly/portability/*.h',
                      'folly/system/*.h',

  # workaround for https://github.com/facebook/react-native/issues/14326
  spec.preserve_paths = 'folly/*.h',
                        'folly/container/*.h',
                        'folly/container/detail/*.h',
                        'folly/detail/*.h',
                        'folly/functional/*.h',
                        'folly/hash/*.h',
                        'folly/lang/*.h',
                        'folly/memory/*.h',
                        'folly/memory/detail/*.h',
                        'folly/net/*.h',
                        'folly/net/detail/*.h',
                        'folly/portability/*.h',
                        'folly/system/*.h',
  spec.libraries           = "c++abi" # NOTE Apple-only: Keep c++abi here due to https://github.com/react-native-community/releases/issues/251
  spec.pod_target_xcconfig = { "USE_HEADERMAP" => "NO",
                               "DEFINES_MODULE" => "YES",
                               "CLANG_CXX_LANGUAGE_STANDARD" => "c++20",
                               "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)\" \"$(PODS_ROOT)/boost\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/fmt/include\"",
                               # In dynamic framework (use_frameworks!) mode, ignore the unused and undefined boost symbols when generating the library.
                               "OTHER_LDFLAGS" => "\"-Wl,-U,_jump_fcontext\" \"-Wl,-U,_make_fcontext\""
                             }

  # TODO: The boost spec should really be selecting these files so that dependents of Folly can also access the required headers.
  spec.user_target_xcconfig = { "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"" }

  spec.default_subspec = 'Default'

  spec.subspec 'Default' do
    # no-op
  end

  spec.subspec 'Fabric' do |fabric|
    fabric.source_files = 'folly/SharedMutex.cpp',
                          'folly/concurrency/CacheLocality.cpp',
                          'folly/detail/Futex.cpp',
                          'folly/synchronization/ParkingLot.cpp',
                          'folly/portability/Malloc.cpp',
                          'folly/concurrency/CacheLocality.h',
                          'folly/synchronization/*.h',
                          'folly/system/ThreadId.h'

    fabric.preserve_paths = 'folly/concurrency/CacheLocality.h',
                            'folly/synchronization/*.h',
                            'folly/system/ThreadId.h'
  end

  # Folly has issues when compiled with iOS 10 set as deployment target
  # See https://github.com/facebook/folly/issues/1470 for details
  spec.platforms = min_supported_versions
end
