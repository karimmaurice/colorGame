class MapsController < ApplicationController

	before_filter :authenticate_user!

	def index
		@list_name = "maps"
		@maps = Map.all
		@locations = Location.all
	end

	def show
		@list_name = "maps"
		@map = Map.find(params[:id])
		@locations = Location.where('map_id=?', @map.id)
		@locationColors = LocationColor.where(:location_id => @locations.map(&:id))
	end

	def new
		@list_name = "maps"
		@map = Map.new
		@colors = ["red", "ornage", "brown", "yellow", "green", "blue", "purple", "grey"]
	end
		
	def create
		@map = Map.create(map_params)
		if params[:locations]
			params[:locations].each do |k, v|
				loc = Location.new
				loc.name = v[:name]
				loc.map_id = @map.id
				loc.save
				#location_color
				i = 0
				v[:image].values.each do |image|
					if image != "-1"
						hash = Hash.new
						hash = {:location_id => loc.id, :image => image, :color => params[:teamColor][i]}
						locColor = LocationColor.create(hash)
					else
						locColor = LocationColor.new
						locColor.location_id = loc.id
						locColor.team = params[:teamColor][i]
						locColor.save
					end
				i += 1
				end
			end
		end
		#return
		redirect_to maps_path, :notice => "Your map has been added successfully"
	end

	def edit
		@list_name = "maps"
		@map = Map.find(params[:id])
		@locations = Location.where('map_id=?', @map.id)
		@locationColors = LocationColor.where(:location_id => @locations.map(&:id))
		@colors = ["red", "ornage", "brown", "yellow", "green", "blue", "purple", "grey"]
	end

	def update
		@map = Map.find(params[:id])
		if map_params[:image] == nil
			@map.name = map_params[:name]
			@map.team_count = map_params[:team_count]
			@map.save
		else
			@map.update_attributes(map_params)
		end
		#locations
		@locations = Location.where('map_id=?', @map.id)
		#update or delete existing locations
		counter = 0
		@locations.each do |location|
			if params[:locations] and params[:locations].count > counter
				#update location
				location.name = params[:locations][counter.to_s][:name]
				location.save
				#location colors
				locCounter = 0
				locColors = LocationColor.where('location_id=?', location.id)
				locColors.each do |locColor|
					if params[:locations][counter.to_s][:image].count > locCounter
						if params[:locations][counter.to_s][:image][locCounter.to_s] != "-1"
							hash = {:location_id => locColor.location_id, :image => params[:locations][counter.to_s][:image][locCounter.to_s], :color => params[:teamColor][locCounter]}
							locColor.update_attributes(hash)
						else
							locColor.color = params[:teamColor][locCounter]
							locColor.save
						end
					else
						locColor.destroy
					end
					locCounter += 1
				end
				# add new location colors
				locCounter = 0
				params[:locations][counter.to_s][:image].values.each do |image|
					if locCounter >= locColors.count
						if image != "-1"
							hash = {:location_id => location.id, :image => image, :color => params[:teamColor][locCounter]}
							locColor = LocationColor.create(hash)
						else
							locColor = LocationColor.new
							locColor.location_id = location.id
							locColor.color = params[:teamColor][locCounter]
							locColor.save
						end
					end
					locCounter += 1
				end
			else
				#delete location
				locationColors = LocationColor.where('location_id=?', location.id)
				locationColors.each do |lc|
					lc.destroy
				end
				location.destroy
			end
			counter += 1
		end
		# add new locations
		counter = 0
		if params[:locations]
			params[:locations].each do |k, v|
				if counter >= @locations.count
					loc = Location.new
					loc.name = v[:name]
					loc.map_id = @map.id
					loc.save
					#location_color
					locCounter = 0
					v[:image].values.each do |image|
						if image != "-1"
							hash = Hash.new
							hash = {:location_id => loc.id, :image => image, :color => params[:teamColor][locCounter]}
							locColor = LocationColor.create(hash)
						else
							locColor = LocationColor.new
							locColor.location_id = loc.id
							locColor.color = params[:teamColor][locCounter]
							locColor.save
						end
						locCounter += 1
					end
				end
				counter += 1
			end
		end
		#return
		redirect_to maps_path, :notice => "Your map has been updated successfully"
	end

	def destroy
		@map = Map.find(params[:id])
		#delete locations
		locations = Location.where('map_id=?', @map.id)
		locations.each do |l|
			#delete location colors
			locationColors = LocationColor.where('location_id=?', l.id)
			locationColors.each do |lc|
				lc.destroy
			end
			l.destroy
		end
		#delete map
  		@map.destroy
  		redirect_to maps_path, :notice => "Your map has been deleted successfully"
		
	end

	def getMapInfo
		map = Map.find(params[:mapID])
		locations = Location.where('map_id=?', map.id).map(&:name)
		colors = LocationColor.joins(:location).where('map_id=?', map.id).map(&:color).uniq
		hash = {locations: locations, team_count: map.team_count, colors: colors}
		return render :text => hash.to_json
	end

	# general functions *******************************************

 	def map_params
 		params.require(:map).permit(:name, :image, :team_count)
 	end

end
