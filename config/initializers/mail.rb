unless Rails.env.test? or Rails.env.cucumber?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
          :domain => 'companiesandme.com',
          :address => 'mail.authsmtp.com',
          :port => 2525,
          :authentication => :login,
          :user_name => 'ac46789',
          :password => 'camlive2010!!'
  }
end