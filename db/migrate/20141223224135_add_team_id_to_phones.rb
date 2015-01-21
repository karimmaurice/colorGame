class AddTeamIdToPhones < ActiveRecord::Migration
  def change
    add_column :phones, :team_id, :integer
  end
end
