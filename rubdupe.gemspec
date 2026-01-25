Gem::Specification.new do |s|
  s.name        = 'rubdupe'
  s.version     = '1.0.0'
  s.summary     = 'Ruby duplicate file detector'
  s.description = 'Intelligent duplicate file detector and sorter with smart grouping'
  s.authors     = ['timappledotcom']
  s.email       = '179739321+timappledotcom@users.noreply.github.com'
  s.files       = Dir['lib/**/*', 'smart_sort.rb', 'README.md', 'Gemfile']
  s.executables << 'smart_sort'
  s.homepage    = 'https://github.com/timappledotcom/rubdupe'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  
  s.add_runtime_dependency 'digest', '~> 3.0'
  s.add_runtime_dependency 'fileutils', '~> 1.0'
end
