namespace :data do
  
  task :factories => [:environment] do
    Factory.definition_file_paths = [File.join(RAILS_ROOT, 'test', 'factories')]
    Factory.find_definitions
  end
  
  task :prevent_production => [:environment] do
    prevent_production
  end
  
  task :demo => [:environment, :prevent_production, 'db:revert', 'default:users', 'demo:companies', 'demo:followings',
                 'demo:representatives', 'demo:posts', 'demo:users', 'demo:comments']
  
  namespace :demo do
    
    task :companies => [:environment, :prevent_production, :factories] do
      8.times do
        Factory(:company, :metro_area => MetroArea.all.rand)
        Company.delete_all("logo_id IS NULL") # RWD Factory girl circular dependency bug?
      end
    end

    task :representatives => [:environment, :prevent_production, :factories] do
      Company.all.each do |c|
        create_users(rand(3) + 2).each_with_index do |u, ndx|
          Factory(:representative, :company => c, :user => u,
                  :representative_role => ndx == 0 ? RepresentativeRole[:admin] :
                          ndx > 1 ? RepresentativeRole[:representative] : RepresentativeRole[:poster])
        end
      end
    end

    task :posts => [:environment, :prevent_production, :factories] do
      Representative.all.each do |r|
        (rand(5) + 1).times { Factory(:post, :user => r.user) }
      end
    end

    desc 'Regular, non-representative users'
    task :users => [:environment, :prevent_production, :factories] do
      create_users(5)
    end

    task :followings => [:environment, :prevent_production, :factories] do
      Company.all.each do |c|
        create_users(rand(2) + 1).each do |u|
          Factory(:following, :followee => c, :user => u)
        end
      end
    end
    
    task :comments => [:environment, :prevent_production, :factories] do
      member_users = User.find(:all, :conditions => ["id NOT IN (?)", Representative.all(:select => 'user_id').collect(&:user_id) ])
      Post.all.each do |p|
        rand(5).times do
          Factory(:comment, :commentable => p, :user => member_users.rand )
        end
      end
    end
  end
  
  namespace :default do
    
    task :users => [:environment, :prevent_production, :factories] do
      ['ryan@digitaltoniq.com', 'dsnider@digitaltoniq.com', 'ryanmickle@gmail.com'].each do |f|
        u = Factory(:user, :email => f, :login => f.split('@').first)
        u.role = Role[:admin]
        u.save!
        User.delete_all("avatar_id IS NULL") # RWD Factory girl circular dependency bug?
      end
    end
  end
end

def prevent_production
  if ENV['RAILS_ENV'] == 'production'           
    raise "Cannot load this data into a production environment.  These tasks are meant only as a way to quickly instantiate a test or staging dataset and does destroy ALL data"
  end
end

def create_users(num)
  users = []
  num.times do
    users << Factory(:user)
    User.delete_all("avatar_id IS NULL") # RWD Factory girl circular dependency bug?
  end
  users
end
