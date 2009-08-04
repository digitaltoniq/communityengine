namespace :db do
  task :revert => ['db:drop', 'db:create', 'db:migrate']
end