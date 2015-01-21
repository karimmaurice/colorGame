class Map < ActiveRecord::Base
	has_many :locations
	has_many :games
	has_attached_file :image, :styles => { :medium => "101x102>", :thumb => "40x40>" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
