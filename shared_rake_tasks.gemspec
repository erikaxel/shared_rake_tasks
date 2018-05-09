# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'shared_rake_tasks'
  s.version     = '1.0.9'
  s.summary     = 'Common DB and Google tasks'
  s.description = 'Common DB and Google tasks'
  s.required_ruby_version = '>= 2.0.0'

  s.author    = 'Erik Axel Nielsen'
  s.email     = 'erikaxel@lucalabs.com'
  s.homepage  = 'http://www.example.com'

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'aws-sdk-s3'
end
