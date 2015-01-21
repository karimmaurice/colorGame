class AddAttachmentImageToChallenges < ActiveRecord::Migration
  def self.up
    change_table :challenges do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :challenges, :image
  end
end
