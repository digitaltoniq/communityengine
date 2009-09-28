class RepresentativeNotifier < ActionMailer::Base
  
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')

  def signup_invitation(company, email, user, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{user} would like you to join #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = representative_signup_by_id_url(company, user, user.invite_code)
    @body[:message] = message
    @body[:company] = company
  end

  def signup_notification(representative)
    setup_email(representative)
    @subject    += "Please activate your new #{AppConfig.community_name} account"
    @body[:representative] = representative
    # TODO remove @body[:url]  = "#{application_url}#{representative.company.to_param}/#{representative.to_param}/activate?activation_code=#{representative.activation_code}"
    # @body[:url] = activate_company_representative_url({ :company => representative.company, :representative => representative, :activation_code => representative.activation_code})
    @body[:url] = representative_activation_url(representative.company, representative, representative.activation_code)
  end

  def activation(representative)
    setup_email(representative)
    @subject    += "Your #{AppConfig.community_name} account has been activated!"
    @body[:representative] = representative
    @body[:url]  = home_url
  end

  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @body[:user] = user
  end

  def setup_sender_info
    @from       = "The #{AppConfig.community_name} Team <#{AppConfig.support_email}>"
    headers     "Reply-to" => "#{AppConfig.support_email}"
    @content_type = "text/plain"
  end

end
