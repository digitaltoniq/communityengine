after 'deploy:update_code', 'engine:appify'

namespace :engine do

  desc 'Do all the linking etc... necessary to get this engine to a proper application setup (on every deploy)'
  task :appify do
    run <<-RUN
      cd #{latest_release} &&\
      RAILS_ENV=#{rails_env} rake engine:appify
    RUN
  end
end
