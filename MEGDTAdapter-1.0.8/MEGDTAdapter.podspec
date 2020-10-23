Pod::Spec.new do |s|
  s.name = "MEGDTAdapter"
  s.version = "1.0.8"
  s.summary = "A adapter of GDT for mediation SDK"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"刘峰"=>"liufeng@mobiexchanger.com"}
  s.homepage = "https://github.com/liusas/MEGDTAdapter.git"
  s.description = "this is a Mobiexchanger's advertise adapter, and we use it as a module"
  s.source = { :path => '.' }

  s.ios.deployment_target    = '9.0'
  s.ios.vendored_framework   = 'ios/MEGDTAdapter.framework'
end
