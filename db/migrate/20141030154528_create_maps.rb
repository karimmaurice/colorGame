class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
    	t.string  :name
    	t.integer :team_count
      	t.timestamps
    end
  end
end
