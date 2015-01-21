class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	has_many :games
  	has_one :device
  	has_one :api_key, dependent: :destroy
  	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	after_create :create_api_key
	def ensure_authentication_token!
		if self.api_key.nil?
			ApiKey.create :user => self
		end
  	end

  	private
  	def create_api_key
    	ApiKey.create :user => self
  	end
end
