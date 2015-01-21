class LocationChallenge < ActiveRecord::Base
	belongs_to :location
	belongs_to :challenge
	belongs_to :team
end
