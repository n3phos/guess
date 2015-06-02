FactoryGirl.define do
  factory :theme do

    video_id "https://www.youtube.com/watch?v=HZUDWKs4HZ0"
    start_seconds 0
    end_seconds 0
    media_name "Star Wars"
    theme_name "Binary Sunset"
    theme_interpret "John Williams"
    media_image_file_name "tatooine.png"
    media_image_content_type "image/png"
    media_image_file_size 2023970
    disabled false
    category

  end

  factory :game_theme, class: Theme do

    video_id "https://www.youtube.com/watch?v=XheJnmLAwhk"
    start_seconds 0
    end_seconds 0
    media_name "Diablo"
    theme_name "Tristram"
    theme_interpret ""
    media_image_file_name "Cain_face.jpg"
    media_image_content_type "image/png"
    media_image_file_size 259534
    disabled false
    association :category, factory: :category, name: "Game"

  end

  factory :series_theme, class: Theme do

    video_id "https://www.youtube.com/watch?v=2pEdUOGhHBg"
    start_seconds 0
    end_seconds 0
    media_name "Boardwalk Empire"
    theme_name "Straight Up and Down"
    theme_interpret ""
    media_image_file_name "Boardwalk-Empire.jpg"
    media_image_content_type "image/png"
    media_image_file_size 763191
    disabled false
    association :category, factory: :category, name: "Series"

  end
end
