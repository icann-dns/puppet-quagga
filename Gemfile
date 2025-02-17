# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :system_tests do
  gem 'beaker', '~> 3.13',         :require => false
  gem 'beaker-pe',                 :require => false
  gem 'beaker-hostgenerator',      :require => false
  gem 'beaker-rspec',              :require => false
  gem 'beaker-testmode_switcher',  :require => false
  gem 'progressbar',               :require => false
end

gem 'rake', :require => false
gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false, :groups => [:test]

puppetversion = ENV['PUPPET_GEM_VERSION'] || [">= 7.24", "< 9"]
gem 'puppet', puppetversion, :require => false, :groups => [:test]

# vim: syntax=ruby
