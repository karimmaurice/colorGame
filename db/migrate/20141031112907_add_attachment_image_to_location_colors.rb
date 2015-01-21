class AddAttachmentImageToLocationColors < ActiveRecord::Migration
  def self.up
    change_table :location_colors do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :location_colors, :image
  end
end
