class Product < ApplicationRecord
	has_many :images, dependent: :destroy
end
