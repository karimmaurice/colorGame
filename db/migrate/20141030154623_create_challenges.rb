class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
    	t.string  :name
    	t.text    :description
    	t.integer :points
    	t.integer :player_count
      	t.timestamps
    end
  end
end
