class Service < ApplicationRecord

	def self.APIindex(userX)
		if userX&.class == User
			return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{userX&.authentication_token}" -X GET #{SITEurl}/v1/products`
		else
			return `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products`
		end
	end
end
