class JobsController < ApplicationController
	before_action :authenticate_user!
	
	def index
		#see all available
	end

	def create
		#chrge then assign
	end

	def update
		#reassign/assign
	end

	def destroy
		#unassign back to open
	end
end