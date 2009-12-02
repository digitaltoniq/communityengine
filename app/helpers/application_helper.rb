# Methods added to this helper will be available to all templates in the application.
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
end
