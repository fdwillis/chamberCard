Cloudinary.config do |config|
  config.cloud_name = ENV['cloudinaryName']
  config.api_key = ENV['cloudinaryKey']
  config.api_secret = ENV['cloudinarySecret']
  config.secure = true
  config.cdn_subdomain = true
end