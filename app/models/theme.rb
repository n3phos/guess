class Theme < ActiveRecord::Base

  belongs_to :category

  has_many :gamerecords
  has_many :games, through: :gamerecords

  has_many :theme_questions
  has_many :questions, through: :theme_questions

  has_attached_file :media_image, :styles => { :medium => "400x400>"}

  validates_attachment_content_type :media_image, :content_type => /\Aimage\/.*\Z/

  accepts_nested_attributes_for :questions


  def generate_record
    record = {
      "video_id" => video_id,
      "entries" => [
        {
          "q" => "#{category.name}",
          "a" => media_name
        }
      ]
    }

    qs = questions.order("RANDOM()").limit(3)

    record["entries"] << { "q" => "Theme", "a" => theme_name } unless theme_name.empty?
    record["entries"] << { "q" => "Interpret", "a" => theme_interpret } unless theme_interpret.empty?

    if(!qs.empty?)
      qs.each do |q|
        record["entries"] << { "q" => q.ques, "a" => q.answer }
      end
    end

    record
  end


end
