require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :all

  def test_should_create_user
    assert_difference Company, :count do
      company = create_company
      assert !company.new_record?, "#{company.errors.full_messages.to_sentence}"
    end
  end

  protected

    def create_company(options = {})
      Company.create({ :name => "TestCompany", :description => "TestCompanyDescription" }.merge(options))
    end
end
