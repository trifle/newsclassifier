require "bundler/vlad"

set :application, "nc3"
set :repository, "http://github.com/mscharkow/newsclassifier.git"

set :user, "deploy"
set :domain, "#{user}@newsclassifier.org"
set :deploy_to, "/home/deploy/apps/#{application}"

task :demo do
  set :deploy_to, "/home/deploy/apps/nc3_demo"
  set :unicorn_command, [ "source ~/.rvm/scripts/rvm", "cd #{deploy_to}/current",
                          "unicorn"].join(" && ")
end

set :bundle_cmd, [  "source ~/.rvm/scripts/rvm",
                    "bundle"].join(" && ")
             
set :unicorn_command, [ "source ~/.rvm/scripts/rvm", "cd #{deploy_to}/current",
                        "unicorn"].join(" && ")


set :symlinks, {  'config/database.yml' => 'config/database.yml',
                  'config/config.yml' => 'config/config.yml',
                  'config/unicorn.rb' => 'config/unicorn.rb',}


namespace :vlad do
  remote_task :start_resque do
    run "source ~/.rvm/scripts/rvm && cd #{deploy_to}/current;
    RAILS_ENV=production nohup rake environment workers:start > log/workers.log 2>&1 &"
  end
  remote_task :stop_resque do
    run "kill `cat #{deploy_to}/current/tmp/pids/resque/*.pid`"
  end
end



task "vlad:deploy" => %w[
  vlad:update vlad:symlink vlad:bundle:install vlad:start_app vlad:stop_resque vlad:start_resque vlad:cleanup
]