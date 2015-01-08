class Theme < ActiveRecord::Base

  has_many :gamerecords
  has_many :games, through: :gamerecords

  has_attached_file :media_image, :styles => { :medium => "400x400>"}

  validates_attachment_content_type :media_image, :content_type => /\Aimage\/.*\Z/


end
