class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
    	t.string  :name
    	t.string  :color
    	t.integer :game_id
      	t.timestamps
    end
  end
end
