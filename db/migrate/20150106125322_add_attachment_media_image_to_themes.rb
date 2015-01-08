class AddAttachmentMediaImageToThemes < ActiveRecord::Migration
  def self.up
    change_table :themes do |t|
      t.attachment :media_image
    end
  end

  def self.down
    remove_attachment :themes, :media_image
  end
end
