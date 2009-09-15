# Force all factory data creation to not spawn mailings
class Factory

  def run_with_mail_prevention(*args)
    ActionMailer::Base.no_deliveries do
      run_without_mail_prevention(*args)
    end
  end

  alias_method_chain :run, :mail_prevention
end
