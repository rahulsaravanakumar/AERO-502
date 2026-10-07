# Google sign-in. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET from the
# organization's Google Cloud OAuth client (see docs/ADMIN_GUIDE.md).
Rails.application.config.middleware.use OmniAuth::Builder do
     provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
              scope: "email,profile", prompt: "select_account"
end

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.on_failure = proc { |env| SessionsController.action(:failure).call(env) }
