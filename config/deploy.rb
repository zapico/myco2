set :application, "MyCO2"
set :repository,  "git://github.com/zapico/myco2.git"
set :scm, :git
set :deploy_to, "/var/www/vhosts/myco2.persuasiveservices.org/rails/myco2"
set :user, "root"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

server "verdemedia.org", :app, :web, :db, :primary => true  