class Product < ApplicationRecord
	has_many :images, dependent: :destroy

	def self.APIindex(userX)
		if userX&.class == User
			return `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products`
		else
			return `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products`
		end
	end

	def self.APIshow(params)
		return `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products/prod_#{params[:id]}?connectAccount=#{params[:connectAccount]}`
	end

	def self.APIcreate(userX, productParams)
		productName = productParams[:name]
		description = productParams[:description]
		type = productParams[:type]
		keywords = productParams[:keywords]

		images = []
		productStarted = Product.create()

		if !productParams['images'].blank?
			productParams['images'].each do |img|
				imageMade = productStarted.images.create(source: img)
				cloudX = Cloudinary::Uploader.upload(imageMade.source.file.file)
				images.append(cloudX['secure_url'])
				File.delete(imageMade.source.file.file)
				productStarted.destroy!
			end
		end

		if userX&.class == User
			callIt = `curl -H "appName: #{ENV['appName']}" -d 'keywords=#{keywords}&images=#{images.join(",")}&type=#{type}&name=#{productName}&description=#{description}&connectAccount=#{userX&.stripeMerchantID}&active=true' -X POST #{SITEurl}/v1/products`
			response = Oj.load(callIt)

			return callIt
		end
	end

	def self.APIupdate(userX, productParams)
		productName = productParams[:name]
		description = productParams[:description]
		type = productParams[:type]
		keywords = productParams[:keywords]
		active = ActiveModel::Type::Boolean.new.cast(productParams[:active])

		images = []

		if !productParams['images'].blank?
			productParams['images'].each do |img|
				productFound = Product.find_by(stripeProductID: "prod_#{productParams[:id]}")
				imageMade = productFound.images.create(source: img)
				
				cloudX = Cloudinary::Uploader.upload(imageMade.source.file.file)
				images.append(cloudX['secure_url'])
				File.delete(imageMade.source.file.file)
			end
		end

		if userX&.class == User
			return `curl -H "appName: #{ENV['appName']}" -d "images=#{images.join(",")}&keywords=#{keywords}&name=#{productName}&description=#{description}&active=#{active}&type=#{type}&connectAccount=#{userX&.stripeMerchantID}" -X PATCH #{SITEurl}/v1/products/#{productParams[:id]}`
		end
	end
end
