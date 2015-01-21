class Location < ActiveRecord::Base
	belongs_to :map
	has_many :location_colors
	has_and_belongs_to_many :challenges , :join_table => :location_challenges
end
