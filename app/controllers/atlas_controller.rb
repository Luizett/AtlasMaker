class AtlasController < ApplicationController
  def index

  end

  def create
    file1 = params[:img1]
    file2 = params[:img2]


    image11 = MiniMagick::Image.open(file1.file.path)
    image22 = MiniMagick::Image.open(file2.file.path)

    width = [image11.width, image22.width].max
    height = image11.height + image22.height

    # Создаем новое изображение с размерами, достаточными для склейки
    result_image = MiniMagick::Image.new("result.jpg") do |img|
      img.combine_options do |c|
        c.size "#{width}x#{height}"
        c.gravity "north"
        c.background "white"
        c.extent "#{width}x#{height}"
      end
    end

    # Склеиваем изображения вертикально
    result_image = result_image.composite(image1) do |c|
      c.compose "Over"
      c.geometry "+0+0"
    end

    result_image = result_image.composite(image2) do |c|
      c.compose "Over"
      c.geometry "+0+#{image1.height}"
    end

    # Сохраняем результат во временный файл
    output_path = Rails.root.join("tmp", "combined_image.jpg")
    result_image.write(output_path)

    # Отправляем результат клиенту
    send_file output_path, type: 'image/jpeg', disposition: 'inline'

    file1.close
    file2.close
    File.delete(output_path) if File.exist?(output_path)
  end
end