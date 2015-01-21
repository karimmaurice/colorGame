class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
    	t.integer :game_id
    	t.string  :token
    	t.string  :uuid
      t.timestamps
    end
  end
end
