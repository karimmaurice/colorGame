class Game < ActiveRecord::Base
	belongs_to :user
	belongs_to :map
	has_many :teams
	has_many :location_challenges
	has_many :events
	has_many :phones
	has_attached_file :image, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
