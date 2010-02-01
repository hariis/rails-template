# My version of an app template, modified by James Cox (imajes)
# SUPER DARING APP TEMPLATE 1.0 - By Peter Cooper


# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"
run "rm -f public/javascripts/*"

# Download JQuery
run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.1.min.js > public/javascripts/jquery.js"
run "curl -s -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Set up git repository
git :init
git :add => '.'

# Copy database.yml for distribution use
run "cp config/database.yml config/database.yml.example"

# Set up .gitignore files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
vendor/rails
END

# Set up session store initializer
initializer 'session_store.rb', <<-END
ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
ActionController::Base.session_store = :active_record_store
  END

# Install plugins

## Potentially Useful 
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'

## user related
if yes?("Will this app have authenticated users?")
  plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git'
  plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
  plugin 'aasm', :git => 'git://github.com/rubyist/aasm.git'
  gem 'ruby-openid', :lib => 'openid'  
  generate("authenticated", "user session")
  generate("roles", "Role User")
end

if yes?("OpenID Support?")
  plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git'
  rake('open_id_authentication:db:create')
end

# tags
if yes?("Do you want tags with that?")
  plugin 'acts_as_taggable_redux', :git => 'git://github.com/geemus/acts_as_taggable_redux.git'
  rake('acts_as_taggable:db:create')
end

# require some gems


# Final install steps
rake('gems:install', :sudo => true)
rake('db:sessions:create')
rake('db:migrate')

first = ask("What'll be your first action?")
generate(:model, first)

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'First POST!'"

# Success!
puts "SUCCESS!"

