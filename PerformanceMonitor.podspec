Pod::Spec.new do |spec|
  spec.name = 'PerformanceMonitor'
  spec.version = '0.0.1'
  spec.license = 'MIT'
  spec.summary = 'PerformanceMonitor is a non-invasive APM system, Including monitoring CPU,Memory,FPS,Recording all OC and Swift methods time consuming,etc.'
  spec.homepage = 'https://github.com/woshiccm/PerformanceMonitor'
  spec.author = "roy"
  spec.source    = { :git => "https://github.com/woshiccm/PerformanceMonitor.git", :tag => spec.version }
  spec.license = 'Code is private.'

  spec.platforms = { :ios => '8.0' }
  spec.requires_arc = true

  spec.cocoapods_version = '>= 1.4'
  spec.swift_version = ['4.2', '5.0']

  spec.source_files = 'PerformanceMonitor/**/*.{h,mm,swift}'

  spec.dependency 'RCBacktrace', '~> 0.1.7'
end
