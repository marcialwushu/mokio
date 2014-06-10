$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mokio/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mokio"
  s.version     = Mokio::VERSION
  s.authors     = ["Adam Stomski, Martyna Kolaczek, Herman Sadik"]
  s.email       = ["test@test.pl"]
  s.homepage    = "http://www.test.pl"
  s.summary     = "Summary of Mokio."
  s.description = "Description of Mokio."

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc", "CHANGELOG"]
  s.test_files  = Dir["spec/**/*"]

# =====================================================================
  s.add_dependency "rake",                        '10.3.1'
  s.add_dependency "rails",                       '~> 4.0.3'

  s.add_dependency 'sass-rails',                  '~> 4.0.0', '>= 4.0.2'
  s.add_dependency 'coffee-rails',                '~> 4.0.0'
  s.add_dependency 'haml-rails',                  '0.5.3'
  s.add_dependency 'fancybox2-rails',             '0.2.8'
  s.add_dependency 'sunspot_rails',               '2.1.0'

  s.add_dependency 'jquery-rails',                '3.1.0'
  s.add_dependency 'jquery-ui-rails',             '4.2.1'
  s.add_dependency "jquery-fileupload-rails",     '0.4.1'
  s.add_dependency 'jquery-datatables-rails',     '1.12.2'

  s.add_dependency "bootstrap-wysihtml5-rails",   '~> 0.3.1.23'
  s.add_dependency "bootstrap-switch-rails",      '2.0.0'

  s.add_dependency 'uglifier',                    '>= 1.3.0'
  s.add_dependency 'cancancan',                   '~> 1.7'  
  s.add_dependency 'simple_form',                 '3.0.2'
  s.add_dependency "ckeditor",                    '4.0.8'
  s.add_dependency "carrierwave",                 '0.10.0'
  s.add_dependency "rmagick",                     '2.13.2'
  s.add_dependency "mini_magick",                 '3.7.0'
  s.add_dependency 'amoeba',                      '2.0.0'           
  s.add_dependency 'youtube_it',                  '2.1.4'
  s.add_dependency 'ancestry',                    '2.1.0'
  s.add_dependency 'acts_as_list',                '0.4.0'
  s.add_dependency 'will_paginate',               '3.0.5'
  s.add_dependency 'faraday',                     '0.7.6'
  s.add_dependency 'validates',                   '0.0.8'
  s.add_dependency 'friendly_id',                 '5.0.3'            
  s.add_dependency 'video_info',                  '2.3.1'
  s.add_dependency 'disqus',                      '1.0.4'
  s.add_dependency 'devise',                      '3.2.4'
  s.add_dependency 'role_model',                  '0.8.1'
  s.add_dependency "deface",                       '1.0.0'
  s.add_development_dependency "rspec",           '~> 2.14.1'
  s.add_development_dependency 'capybara',        '2.2.1'
  s.add_development_dependency 'factory_girl_rails', '4.4.1'

end
