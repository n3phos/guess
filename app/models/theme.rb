class Theme < ActiveRecord::Base

  belongs_to :category

  has_many :gamerecords
  has_many :games, through: :gamerecords

  has_attached_file :media_image, :styles => { :medium => "400x400>"}

  validates_attachment_content_type :media_image, :content_type => /\Aimage\/.*\Z/


  def generate_record
    record = {}

    record["#{category.name}"] = media_name unless media_name.empty?
    record["Theme"] = theme_name unless theme_name.empty?
    record["Interpret"] = theme_interpret unless theme_interpret.empty?

    record
  end


end
