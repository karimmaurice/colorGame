class UserController < ApplicationController

	before_filter :authenticate_user!

	def index
		@list_name = "users"
		@users = User.all
	end

	def show
		@list_name = "users"
		@user = User.find(params[:id])
	end

	def new
		@list_name = "users"
		@user = User.new
	end

	def create
		@user = User.new
		@user.name = user_params[:name]
		@user.email = user_params[:email]
		@user.password = user_params[:password]
		@user.role = "Admin"
		@user.save
		#return
		redirect_to user_index_path, :notice => "Your user has been added successfully"
	end

	def edit
		@list_name = "users"
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		@user.update(user_params)
		#return
		redirect_to user_index_path, :alert => "Your passwod was incorrect"
	end

	def destroy
		@user = User.find(params[:id])
		@user.destroy
		#return
		redirect_to user_index_path, :notice => "Your user has been deleted successfully"
	end

	# general functions *******************************************

 	def user_params
 		params.require(:user).permit(:name, :email, :password)
 	end
 	
end
