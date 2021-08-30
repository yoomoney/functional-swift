Pod::Spec.new do |spec|
  spec.name         = 'FunctionalSwift'
  spec.version      = '1.7.1'
  spec.license = {
    :type => "MIT",
    :file => "LICENSE"
  }
  spec.homepage     = 'https://github.com/yoomoney/functional-swift'
  spec.authors      = {
    'Alexander Zalutskiy' => 'metalhead.sanya@gmail.com'
  }
  spec.summary      = 'Categories and arrows (morphisms) for swift language.'
  spec.source       = { :git => "https://github.com/yoomoney/functional-swift.git", :tag => "1.7.1" }
  spec.module_name  = 'FunctionalSwift'

  spec.swift_version = '5.0'

  spec.ios.deployment_target  = '9.0'
  spec.osx.deployment_target = '10.10'
  spec.watchos.deployment_target = '3.0'

  spec.source_files = 'FunctionalSwift/**/*.swift'
end