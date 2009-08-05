# Hook into cap deployment lifecycle to get our app specific configs
after 'deploy:setup', 'candme:setup'

namespace :candme do

  NGINX_DIR = "/etc/nginx/servers"
  NGINX_CONF = "#{application}.conf"
  NGINX_CONF_PATH = "#{NGINX_DIR}/#{NGINX_CONF}"

  desc "Setup the target env to serve the C&Me app.  Is not destructive."
  task :setup do
    setup_nginx_proxying
    setup_nginx_auth
  end

  task :setup_nginx_proxying, :roles => :web, :except => { :no_release => true } do

    # Let Rails handle the stylesheets requests so it can route to themes
    run <<-RUN
      cd #{NGINX_DIR} && \
      if [ 1 == `grep -c 'images|javascripts|stylesheets' #{NGINX_CONF}` ] ; then
        cp #{NGINX_CONF} #{NGINX_CONF}-orig.#{Time.now.to_i};
        mv #{NGINX_CONF} keep.#{NGINX_CONF};
        sed -i 's/images|javascripts|stylesheets/images|javascripts/g' keep.#{NGINX_CONF};
        ln -nfs keep.#{NGINX_CONF} #{NGINX_CONF};
      fi
    RUN
  end

  task :setup_nginx_auth, :roles => :web, :except => { :no_release => true } do

    if requires_auth?

      # Make sure nginx knows of our users
      # TODO: Could pull out users/passwords into yml file...
      USERS_FILE = "#{NGINX_DIR}/#{application}.users"
      run "echo '' > #{USERS_FILE}"
      {"digitaltoniq" => "clubsoda"}.each do |name, password|
        run "htpasswd -nb #{name} #{password} > #{USERS_FILE}"
      end

      # Protect everything
      ZONE = "DigitalToniq Staging Environment"
      KEEP_FILE = "keep.#{NGINX_CONF}"
      run <<-RUN
        cd #{NGINX_DIR} && \
        if [ 0 == `grep -c auth_basic #{KEEP_FILE}` ] ; then
          sed -i '4i  auth_basic "#{ZONE}";\n' keep.#{NGINX_CONF};
          sed -i '5i  auth_basic_user_file "#{USERS_FILE}";' keep.#{NGINX_CONF};
        fi
      RUN
    end
  end
end


# TODO: Hard coded, better way to add this env-specific dependency?
# Could add variable to staging/client block in deploy.rb to make less env.-specific,
# but that would pollute deploy.rb which I'm trying to keep as close to EY's original
# as possible
def requires_auth?
  rails_env == 'staging'
end
