require File.dirname(__FILE__) + '/../test_helper'

class RepresentativeTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :all

  def test_should_create_representative
    assert_difference Representative, :count do
      representative = create_representative
      assert !representative.new_record?, "#{representative.errors.full_messages.to_sentence}"
    end
  end

  protected

    def create_representative(options = {})
      Representative.create({ :first_name => "Joe", :last_name => "Tester", :title => "TestTitle" }.merge(options))
    end
end
