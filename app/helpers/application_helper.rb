module ApplicationHelper

  def fb_login
    <<-EOS
      #{fb_login_button("requestFBEmailPermission();")}
      <script type="text/javascript">
        function requestFBEmailPermission() { FB.Connect.showPermissionDialog("email", linkFBAccount); }
        function linkFBAccount(permissions) { window.location = "/users/link_user_accounts" }
      </script>
    EOS
  end

  def return_to_path
    return_params = params.reject { |k, v| [:return_to.to_s].include?(k.to_s) }
    url_for(return_params)
  end
end
