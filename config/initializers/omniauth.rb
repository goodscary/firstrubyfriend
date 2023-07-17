Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production? # You should replace it with your provider
  provider :github, "clientid", "secret id", scope: "user:email"
end
