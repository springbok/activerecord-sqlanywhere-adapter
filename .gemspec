Gem::Specification.new do |gem|
  gem.authors = ["Eric Farrar"]
  gem.email = 'eric.farrar@ianywhere.com'
  gem.name = 'activerecord-sqlanywhere-adapter'
  gem.summary = 'ActiveRecord driver for SQL Anywhere'
  gem.description = <<-EOF
    ActiveRecord driver for SQL Anywhere
  EOF
  gem.version = pkg_version
  gem.has_rdoc = true
  gem.rubyforge_project = 'sqlanywhere'
  gem.homepage = 'http://sqlanywhere.rubyforge.org'  
  gem.files = Dir['lib/**/*.rb'] + Dir['test/**/*']
  gem.required_ruby_version = '>= 1.9.2'
  gem.require_paths = ['lib']
  gem.add_dependency('sqlanywhere', '>= 0.1.5')
  gem.add_dependency('activerecord', '>= 3.0.3')
  gem.rdoc_options << '--title' << 'ActiveRecord Driver for SQL Anywhere' <<
                       '--main' << 'README' <<
                       '--line-numbers'
  gem.extra_rdoc_files = ['README', 'CHANGELOG', 'LICENSE']  
end
