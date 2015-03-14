$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name    = 'swf_fu'
  s.version = '1.0.0'
  s.date    = '2015-03-13'
  s.summary = 'guess!'
  s.description = 'swfu gem for guess'
  s.authors = ['nephos']
  s.email = 'fake@street.to'
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "coffee-script"


  s.add_development_dependency "shoulda-context"
end
