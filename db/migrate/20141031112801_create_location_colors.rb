class CreateLocationColors < ActiveRecord::Migration
  def change
    create_table :location_colors do |t|
    	t.integer :location_id
    	t.string :color
      	t.timestamps
    end
  end
end
