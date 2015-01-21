class CreateLocationChallenges < ActiveRecord::Migration
  def change
    create_table :location_challenges do |t|
    	t.integer :game_id
    	t.integer :location_id
    	t.integer :challenge_id
    	t.integer :team_id
    	t.integer :score
      t.timestamps
    end
  end
end
