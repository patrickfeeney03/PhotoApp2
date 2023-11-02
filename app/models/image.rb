class Image < ApplicationRecord
  has_one_attached :picture

  before_save :resize

  def resize
    p "#{@image}"
    p "#{@image.picture}"
    image = MiniMagick::Image.new(picture.download)
    image.send(:resize, "300x300")
    picture.attach(io: File.open(image.path), filename: picture.filename)
  end

end