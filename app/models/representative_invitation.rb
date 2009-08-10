class RepresentativeInvitation < ActiveRecord::Base
  acts_as_activity :representative  # TODO: activity on representative?

  belongs_to :representative

  after_save :send_invite   # TODO: user run later?

  validates_presence_of :representative
  validates_presence_of :email_addresses
  validates_length_of :email_addresses, :minimum => 6
  validates_length_of :email_addresses, :maximum => 1500

  # TODO: take out side effect of updating email_addresses, don't use collection as yield values, and remove formatting
  validates_each :email_addresses do |record, attr, email_addresses|
    email_addresses.validate(/[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/) do |emails, invalid_emails|
      record.errors.add(:email_addresses, " included invalid addresses: " + invalid_emails.join(', '))
      record.email_addresses = (emails - invalid_emails).join(', ')
    end

    emails = email_addresses.split(',').collect(&:strip).uniq
    invalid_by_domain_emails = emails.reject { |email| record.representative.company.accepts_email?(email) }   # TODO: move format check to accepts_email
    # TODO: better message, localize
    record.errors.add(:email_addresses, " included addresses with a domain not related to your company: " +
            invalid_by_domain_emails.join(', ')) unless invalid_by_domain_emails.empty?
  end

  def send_invite
    emails = self.email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each do |email|
      UserNotifier.deliver_signup_invitation(email, self.representative.user, self.message)    # TODO: use RepresentativeNotifier?
    end
  end

end
