Gem::Specification.new do |s|
  s.name        = 'big-o'
  s.version     = '0.2.0'
  s.date        = '2012-07-27'
  s.summary     = "Calculate function complexity (using Big O notation)"
  s.description = "Big-O is a gem which analyses an anonymous function and verifies that it " +
                  "follows a specific pattern in its execution time."
  s.authors     = ["Vincent Bonmalais"]
  s.email       = 'vbonmalais@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec`.split("\n")
  s.homepage    = 'https://github.com/kouno/big-o'

  s.add_development_dependency('rake', '~>0.9.2')
  s.add_development_dependency('yard', '~>0.8.2')
  s.add_development_dependency('rspec', '~>2.10.0')
  s.add_development_dependency('simplecov', '~>0.6.4')
end
