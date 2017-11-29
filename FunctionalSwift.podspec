Pod::Spec.new do |spec|
  spec.name         = 'FunctionalSwift'
  spec.version      = '1.0.0'
  spec.license = { 
    :type => "MIT", 
    :file => "LICENSE" 
  }
  spec.homepage     = 'https://github.com/yandex-money/functional-swift'
  spec.authors      = {
    'Alexander Zalutskiy' => 'metalhead.sanya@gmail.com'
  }
  spec.summary      = 'Categories and arrows (morphisms) for swift language.'
  spec.source       = { 
    :git => 'https://github.com/yandex-money/functional-swift.git',
    :tag => spec.version.to_s
  }
  spec.module_name  = 'FunctionalSwift'

  spec.ios.deployment_target  = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'

  spec.source_files = 'FunctionalSwift/**/*.swift'
end
