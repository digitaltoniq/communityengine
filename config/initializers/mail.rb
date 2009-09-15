if Rails.env.client?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
          :domain => 'digitaltoniq.com',
          :perform_deliveries => true,
          :address => 'mail.authsmtp.com',
          :port => 2525,
          :authentication => :login,
          :user_name => 'ac43514 ',
          :password => 'pshp7wfhh'
  }
end
