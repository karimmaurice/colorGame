class ChallengesController < ApplicationController

	before_filter :authenticate_user!

	def index
		@list_name = "challenges"
		@challenges = Challenge.all
	end

	def show
		@list_name = "challenges"
		@challenge = Challenge.find(params[:id])
	end

	def new
		@list_name = "challenges"
		@challenge = Challenge.new
	end

	def create
		@challenge = Challenge.create(challenge_params)
		#return
		redirect_to challenges_path, :notice => "Your challenge has been added successfully"
	end

	def edit
		@list_name = "challenges"
		@challenge = Challenge.find(params[:id])
	end

	def update
		@challenge = Challenge.find(params[:id])
		@challenge.update_attributes(challenge_params)
		#return
		redirect_to challenges_path, :notice => "Your challenge has been updated successfully"
	end

	def destroy
		@challenge = Challenge.find(params[:id])
		@challenge.destroy
		#return
		redirect_to challenges_path, :notice => "Your challenge has been deleted successfully"
	end

	# general functions *******************************************

 	def challenge_params
 		params.require(:challenge).permit(:name, :points, :player_count, :description, :image)
 	end

end
