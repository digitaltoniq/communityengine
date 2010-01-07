namespace :data do
  
  task :factories => [:environment] do
    Factory.definition_file_paths = [File.join(RAILS_ROOT, 'test', 'factories')]
    Factory.find_definitions
  end
  
  task :prevent_production => [:environment] do
    prevent_production
  end
  
  task :demo => [:environment, :prevent_production, 'demo:prefetch_images', 'default:users', 'demo:companies',
                 'demo:representatives', 'demo:representative_invitations', 'demo:posts', 'demo:users',
                 'demo:followings', 'demo:comments', 'demo:likes']
  
  namespace :demo do

    task :reset => ['db:revert', 'data:demo']

    # TODO: move to image/cache namespace?
    task :prefetch_images => :environment do
      required_photos.each do |tags, count|
        DT::FlickrDownloader.register(:tags => tags, :count => count, :size => :small)
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
          Factory(:representative, :company => c, :user => u)
        end
      end
    end

    task :representative_invitations => [:environment, :prevent_production, :factories] do
      Representative.all.each do |r|
        (rand(3) + 1).times { Factory(:representative_invitation, :user => r.user) }
      end
      User.admin.each do |a|
        (rand(3) + 1).times { Factory(:representative_invitation, :user => a) }
      end
    end

    task :posts => [:environment, :prevent_production, :factories] do
      Representative.all.each do |r|
        (rand(3) + 1).times { Factory(:post, :user => r.user) }
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

    task :likes => [:environment, :prevent_production, :factories] do
      Comment.all.each do |c|
        rand(3).times { User.all.rand.likes!(c) }
      end
    end
  end
  
  namespace :default do
    
    task :users => [:environment, :factories] do
      users = ['ryan@digitaltoniq.com', 'dsnider@digitaltoniq.com']
      users << 'ryan@companiesandme.com' if Rails.env.client? or Rails.env.production?
      users.each do |f|
        Factory(:user, :email => f, :role => Role[:admin])
        User.delete_all("avatar_id IS NULL") # RWD Factory girl circular dependency bug?
      end
    end
  end
end

# NOTE: Keep in synch with photo|logo|feature_image|post factories
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
