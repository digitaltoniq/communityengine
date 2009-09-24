namespace :data do
  
  task :factories => [:environment] do
    Factory.definition_file_paths = [File.join(RAILS_ROOT, 'test', 'factories')]
    Factory.find_definitions
  end
  
  task :prevent_production => [:environment] do
    prevent_production
  end
  
  task :demo => [:environment, :prevent_production, 'demo:reset_image_cache', 'demo:prefetch_images', 'default:users', 'demo:companies',
                 'demo:representatives', 'demo:posts', 'demo:users', 'demo:followings', 'demo:comments', 'demo:reset_image_cache']
  
  namespace :demo do

    task :reset => ['db:revert', 'data:demo']

    # TODO: move to image/cache namespace?
    task :prefetch_images do
      required_photos.each do |tags, count|
        DT::FlickrDownloader.prime_cache(:tags => tags, :count => count, :size => :small)
      end
    end

    task :reset_image_cache do
      required_photos.each do |tags, count|
        DT::FlickrDownloader.reset!(:tags => tags)
      end
    end

    
    task :companies => [:environment, :prevent_production, :factories] do
      5.times do
        Factory(:company)
        Company.delete_all("logo_id IS NULL") # RWD Factory girl circular dependency bug?
      end
    end

    task :representatives => [:environment, :prevent_production, :factories] do

      # Create an easily remember company users
      c = Company.all.rand
      RepresentativeRole.all.each do |role|
        Factory(:representative, :company => c, :user => Factory(:user, :login => role.name), :representative_role => role)
      end

      # Fill in with random reps 
      Company.all.each do |c|
        create_users(rand(5) + 2).each_with_index do |u, ndx|
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
      User.all.each do |u|
        (rand(2) +5).times do
          Following.follow!(u, Company.all.rand)
        end
      end
    end
    
    task :comments => [:environment, :prevent_production, :factories] do

      member_users = User.find(:all, :conditions => ["id NOT IN (?)", Representative.all(:select => 'user_id').collect(&:user_id) ])
      Post.all.each do |p|
        (rand(20) + 3).times do
          Factory(:comment, :commentable => p, :user => member_users.rand )
        end
      end

      # Participating reps
      Post.all.each do |p|
        (rand(2) + 1).times do
          Factory(:comment, :commentable => p, :user => Representative.for_user(p.user).company.representatives.rand.user)
        end
      end
    end
  end
  
  namespace :default do
    
    task :users => [:environment, :factories] do
      users = ['ryan@digitaltoniq.com', 'dsnider@digitaltoniq.com']
      users << 'ryanmickle@gmail.com' if Rails.env.client? or Rails.env.production?
      users.each do |f|
        Factory(:user, :email => f, :login => f.split('@').first, :role => Role[:admin])
        User.delete_all("avatar_id IS NULL") # RWD Factory girl circular dependency bug?
      end
    end
  end
end

def required_photos
  { 'headshot,portrait' => 50, 'logo' => 10, 'recycling,green' => 150 }
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
