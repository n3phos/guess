class Theme < ActiveRecord::Base

  belongs_to :category

  has_many :gamerecords
  has_many :games, through: :gamerecords

  has_many :theme_questions
  has_many :questions, through: :theme_questions

  has_one :submission, :dependent => :destroy

  has_attached_file :media_image, :styles => { :medium => "400x400>"}

  validates_attachment_content_type :media_image, :content_type => /\Aimage\/.*\Z/

  accepts_nested_attributes_for :questions


  def generate_record
    record = {
      "video_id" => video_id,
      "entries" => []
    }

    first_q = { "q" => "#{category.name}", "a" => media_name }

    qs_pool = []

    qs = questions.order("RANDOM()").limit(3)

    qs_pool << { "q" => "Theme", "a" => theme_name } unless theme_name.empty?
    qs_pool << { "q" => "Interpret", "a" => theme_interpret } unless theme_interpret.empty?

    if(!qs.empty?)
      qs.each do |q|
        qs_pool << { "q" => q.ques, "a" => q.answer }
      end
    end

    qs_pool = qs_pool.shuffle
    qs_pool.insert(0, first_q)

    record["entries"] = qs_pool

    record
  end


end
