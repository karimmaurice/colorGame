class Team < ActiveRecord::Base
	belongs_to :game
	has_many   :location_challenges
	has_many   :phones
end
