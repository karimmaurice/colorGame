class Event < ActiveRecord::Base
	belongs_to :challenge
	belongs_to :game
end
