class GamesController < ApplicationController

	before_filter :authenticate_user!

	def index
		@list_name = "games"
		@games = Game.all
	end

	def show
		@list_name = "games"
		@game = Game.find(params[:id])
		@locations = Location.where('map_id=?', @game.map_id)
		@locChallenges = LocationChallenge.where('game_id=?', @game.id)
		@teams = Team.where('game_id=?', @game.id)
	end

	def new
		@list_name = "games"
		@game = Game.new
		@maps = Map.all
		@users = User.all
		@challenges = Challenge.all
	end

	def create
		@game = Game.create(game_params)
		i = 0
		params[:teamName].each do |teamName|
			team = Team.new
			team.game_id = @game.id
			team.name = teamName
			team.color = params[:teamColor][i]
			team.save
			i += 1
		end
		i = 0
		locations = Location.where('map_id=?', @game.map_id).map(&:id)
		params[:location].each do |challenge|
			if challenge != "-1"
				l = LocationChallenge.new
				l.game_id = @game.id
				l.challenge_id = challenge
				l.location_id = locations[i]
				l.save
			end
			i += 1
		end
		#return
		redirect_to games_path, :notice => "Your game has been added successfully" 
	end

	def edit
		@list_name = "games"
		@game = Game.find(params[:id])
		@locations = Location.where('map_id=?', @game.map_id)
		@locChallenges = LocationChallenge.where('game_id=?', @game.id)
		@teams = Team.where('game_id=?', @game.id)
		@challenges = Challenge.all
		@users = User.all
		@colors = LocationColor.joins(:location).where('map_id=?', @game.map_id).map(&:color).uniq
	end

	def update
		@game = Game.find(params[:id])
		@game.update_attributes(game_params)
		#teams
		@teams = Team.where('game_id=?', @game.id)
		i = 0
		@teams.each do |team|
			if team.name != params[:teamName][i] or team.color != params[:teamColor][i]
				team.name = params[:teamName][i]
				team.color = params[:teamColor][i]
				team.save
			end
			i += 1
		end
		#locations
		i = 0
		locations = Location.where('map_id=?', @game.map_id).map(&:id)
		params[:location].each do |challenge|
			if challenge != "-1"
				l = LocationChallenge.where('game_id=? and location_id=?', @game.id, locations[i]).first
				if l
					l.challenge_id = challenge
					l.save
				else
					l = LocationChallenge.new
					l.game_id = @game.id
					l.challenge_id = challenge
					l.location_id = locations[i]
					l.save
				end
			else
				l = LocationChallenge.where('game_id=? and location_id=?', @game.id, locations[i]).first
				l.destroy if l
			end
			i += 1
		end
		#return
		redirect_to games_path, :notice => "Your game has been updated successfully" 
	end

	def destroy
		@game = Game.find(params[:id])
		#teams
		teams = Team.where('game_id=?', @game.id)
		teams.each do |team|
			team.destroy
		end
		#location challenges
		locChallenges = LocationChallenge.where('game_id=?', @game.id)
		locChallenges.each do |lc|
			lc.destroy
		end
		@game.destroy
		#events
		events = Event.where('game_id=?', @game.id)
		events.each do |e|
			e.destroy
		end
		#phones
		phones = Phone.where('game_id=?', @game.id)
		phones.each do |p|
			p.destroy
		end
		#return
		redirect_to games_path, :notice => "Your game has been deleted successfully" 
	end

	# general functions *******************************************

 	def game_params
 		params.require(:game).permit(:name, :image, :user_id, :map_id, :pass_code)
 	end

end
