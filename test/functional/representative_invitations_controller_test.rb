require File.dirname(__FILE__) + '/../test_helper'

class RepresentativeInvitationsControllerTest < ActionController::TestCase
  fixtures :representative_invitations, :representatives, :representative_roles

  def setup
    @controller = RepresentativeInvitationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    representative_login_as :joe 
    get :index, :company_id => representatives(:joe).company.id, :representative_id => representatives(:joe).to_param, :user_id => representatives(:joe).user
    assert_response :success
    assert assigns(:invitations)
  end

  def test_should_get_new
    representative_login_as :joe
    get :new, :company_id => representatives(:joe).company.to_param, :representative_id => representatives(:joe).to_param
    assert_response :success
  end

  def test_should_create_invitation_in_welcome_steps
    r = representatives(:joe)
    representative_login_as :joe
    assert_difference RepresentativeInvitation, :count, 1 do
      post :create, :company_id => r.company.to_param, :representative_id => r.to_param, :representative_invitation => {:message => 'sup dude', :email_addresses => 'asdf@starbucks.com' }, :welcome => 'complete'
      assert_redirected_to welcome_complete_company_representative_path(r.company, r)
    end    
  end
  
  def test_should_create_representative_invitation
    r = representatives(:joe)
    representative_login_as :joe
    assert_difference RepresentativeInvitation, :count, 1 do
      post :create, :company_id => r.company.to_param, :representative_id => r.to_param, :representative_invitation => {:message => 'sup dude', :email_addresses => 'asdf@starbucks.com' }
      assert_redirected_to company_representative_path(representatives(:joe).company, representatives(:joe))
    end    
  end

  def test_should_fail_to_create_invitation_because_email_not_acceptable_by_company
    r = representatives(:joe)
    representative_login_as :joe
    assert_no_difference RepresentativeInvitation, :count do
      post :create, :company_id => r.company.to_param, :representative_id => r.to_param, :representative_invitation => {:message => 'sup dude', :email_addresses => 'bob@bogus.com' }
    end    
    assert_response :success
    assert assigns(:representative_invitation).errors.on(:email_addresses)
  end

end
