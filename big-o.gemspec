Gem::Specification.new do |s|
  s.name        = 'big-o'
  s.version     = '0.1'
  s.date        = '2012-07-25'
  s.summary     = "Calculate function complexity (using Big O notation)"
  s.description = "Big-O is a gem which analyse an anonymous function and verify that it " +
      "follow a specific pattern in its memory usage or its execution time."
  s.authors     = ["Vincent Bonmalais"]
  s.email       = 'vbonmalais@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec`.split("\n")
  s.homepage    = 'https://github.com/kouno/big-o'

  s.add_development_dependency('rspec', '~>2.10.0')
end