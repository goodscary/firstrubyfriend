Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production? # You should replace it with your provider
  provider :github, Rails.application.credentials.dig(:github, :KEY), Rails.application.credentials.dig(:github, :SECRET), scope: "user:email"
end
