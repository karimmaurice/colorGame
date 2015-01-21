class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

  	# if database is empty create admin
	users = User.where('role=?', "Admin").first
	if !users
		@user = User.new
		@user.email = "admin@solacecontrols.com"
		@user.name = "Admin"
		@user.role = "Admin"
		@user.password = "12345678"
		@user.save
	end
end
