class Challenge < ActiveRecord::Base
	has_many :events
	has_and_belongs_to_many :locations , :join_table => :location_challenges
	has_attached_file :image, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
