if Rails.env.development? || Rails.env.test?
  @site = "http://localhost:3001"
elsif Rails.env.production?
  @site = ENV['SITEurl'] #production API link
end 
 
SITEurl = @site
