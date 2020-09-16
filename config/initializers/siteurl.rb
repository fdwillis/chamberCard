if Rails.env.development? || Rails.env.test?
  @site = "http://localhost:3000"
elsif Rails.env.production?
  @site = ENV['SITEurl']
end 
 
SITEurl = @site
