require "bundler/capistrano"

server "50.116.34.120", :web, :app, :db, :primary => true

set :application, "webcidadania"
set :user, "cidadedemocratica"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:marcosmlopes/#{application}.git"
set :branch, "master"
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do; end
  task :stop do; end
  task :ativar_manutencao, :roles => :app, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/manutencao.txt"
  end
  task :desativar_manutencao, :roles => :app, :except => { :no_release => true } do
    run "rm #{deploy_to}/current/tmp/manutencao.txt"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :setup_config, :roles => :app do
    sudo "ln -nfs #{current_path}/config/apache.conf /etc/apache2/sites-available/#{application}"
  end
  after "deploy:setup", "deploy:setup_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, :roles => :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
