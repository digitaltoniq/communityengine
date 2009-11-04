class FeatureImagesController < BaseController

  inherit_resources
  actions :create, :update
  respond_to :js

  before_filter :login_required

  def create
    create! do |format|
      format.js do
        flash[:notice] = nil
        responds_to_parent do
          render :update do |page|
            page.replace_html 'feature_image', :partial => 'posts/feature_image',
                              :locals => { :feature_image => @feature_image }
            page['post_feature_image_id'].value = @feature_image.id 
          end
        end
      end
    end
  end

  def update
    update! do |format|
      format.js do
        flash[:notice] = nil
        responds_to_parent do
          render :update do |page|
            page.replace_html 'feature_image', :partial => 'posts/feature_image',
                              :locals => { :feature_image => @feature_image }
          end
        end
      end
    end
  end

  private

  #-- Inherited resources overrides

  def begin_of_association_chain
    current_user if action_name == 'create'
  end
end
