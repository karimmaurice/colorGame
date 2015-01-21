class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
    	t.string  :name
    	t.integer :user_id
    	t.integer :map_id
    	t.string  :pass_code
     	t.timestamps
    end
  end
end
