class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
    	t.integer :team_won
    	t.integer :team_lost
    	t.integer :challenge_id
    	t.integer :game_id
      t.timestamps
    end
  end
end
