class RepresentativeInvitation < ActiveRecord::Base

  acts_as_activity :representative, :about => :company

  belongs_to :user
  belongs_to :company

  after_save :send_invite

  validates_presence_of :user
  validates_presence_of :company
  validates_presence_of :email_addresses
  validates_length_of :email_addresses, :minimum => 6
  validates_length_of :email_addresses, :maximum => 1500

  named_scope :by, lambda { |user| { :conditions => { :user_id => user }}}
  named_scope :for, lambda { |company| { :conditions => { :company_id => company }}}

  # TODO: take out side effect of updating email_addresses, don't use collection as yield values, and remove formatting
  validates_each :email_addresses, :if =>  Proc.new { |r| r.email_addresses? } do |record, attr, email_addresses|
    email_addresses.validate(/[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/) do |emails, invalid_emails|
      record.errors.add(:email_addresses, " included invalid addresses: " + invalid_emails.join(', '))
      record.email_addresses = (emails - invalid_emails).join(', ')
    end

    emails = email_addresses.split(',').collect(&:strip).uniq
    invalid_by_domain_emails = emails.reject { |email| record.company.accepts_email?(email) }   # TODO: move format check to accepts_email
    # TODO: better message, localize
    record.errors.add(:email_addresses, " included addresses with a domain not related to your company: " +
            invalid_by_domain_emails.join(', ')) unless invalid_by_domain_emails.empty?
  end

  def send_invite
    emails = self.email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each do |email|
      RepresentativeNotifier.deliver_signup_invitation(company, email, user, message)
    end
  end

  def accepted_users
    @accepted_users ||= User.find(:all, :conditions => { :email => email_address_list })
  end

  def pending_emails
    @pending_emails ||= email_address_list - accepted_users.collect(&:email)
  end

  # TODO: Really should split on invitation creation into individual invites?
  def email_address_list
    @email_address_list ||= email_addresses.split(',').collect(&:strip)
  end

end
