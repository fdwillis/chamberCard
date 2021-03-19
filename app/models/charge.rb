class Charge < ApplicationRecord
	def self.APIindex(userX)
		if userX&.class == User
			return `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{userX&.authentication_token}" -d "" -X GET #{SITEurl}/v1/charges`
		end
	end
end