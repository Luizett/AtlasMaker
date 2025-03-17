require 'mini_magick'

class ImagesController < ApplicationController
  def index

  end
  def create

    #puts params[:img1]

    # puts params[:img1].path
    if params[:img1] && params[:img2]
      # puts "images  not null"
      image1 = MiniMagick::Image.open(params[:img1].path)
      image2 = MiniMagick::Image.open(params[:img2].path)
      # puts "images opened"

      # puts image1.width
      # puts image1.height
      # puts image2.width
      # puts image2.height

      width = image1.width + image2.width
      height = [image1.height, image2.height].max

      # puts width
      # puts height
      # puts "size checked"

      size = width.to_s + "x" + height.to_s
      # puts size
      # base_image = MiniMagick::Image.open("app/assets/images/icons/mushroom2.png")
      # base_image = base_image.resize("#{width}x#{height}!")
      # puts base_image.width
      # puts base_image.height


      # puts "res img created"
      #
      # base_image = base_image.composite(image1) do |c|
      #   c.compose "Over"
      #   c.geometry "+0+0"
      # end
      #
      # base_image = base_image.composite(image2) do |c|
      #   c.compose "Over"
      #   c.geometry "+#{image1.width}+0"
      # end

      # output_path = Rails.root.join("tmp", "combined_image.jpg")
      # base_image.write(output_path)

      #send_file output_path, type: 'image/jpeg', disposition: 'inline'




      MiniMagick.convert do |convert|
        #convert.resize(size)
        convert.merge! ["-size", size, "canvas:transparent", "PNG32:tmp/tmp.png"]
        #convert << "tmp/tmp.png"
      end

      tmp = MiniMagick::Image.open("tmp/tmp.png")

      tmp = tmp.composite(image1) do |c|
        c.compose "Over"
        c.geometry "+0+0"
      end

      tmp = tmp.composite(image2) do |c|
        c.compose "Over"
        c.geometry "+#{image1.width}+0"
      end

      output_path = Rails.root.join("tmp", "combined_image.jpg")
      tmp.write(output_path)

      send_file output_path, type: 'image/jpeg', disposition: 'inline'

      #res = tmp.to_blob

      #send_file Base64.strict_encode64(res), type: 'image/jpeg', disposition: 'inline'


    end

    # image1 = Image.new
    # image1.file.attach(params[:img1])
    #
    # image2 = Image.new
    # image2.file.attach(params[:img2])

    # image11 = MiniMagick::Image.open(image1.file.path)
    # image22 = MiniMagick::Image.open(image2.file.path)

    # image11 = MiniMagick::Image.open(Rails.root.join("app/assets/images/icons/mushroom1.png"))
    # image22 = MiniMagick::Image.open(Rails.root.join("app/assets/images/icons/mushroom2.png"))
    #
    # width = [image11.width, image22.width].max
    # height = image11.height + image22.height
    #
    # # Создаем новое изображение с размерами, достаточными для склейки
    # result_image = MiniMagick::Image.new("result.jpg") do |img|
    #   img.combine_options do |c|
    #     c.size "#{width}x#{height}"
    #     c.gravity "north"
    #     c.background "white"
    #     c.extent "#{width}x#{height}"
    #   end
    # end
    #
    # # Склеиваем изображения вертикально
    # result_image = result_image.composite(image11) do |c|
    #   c.compose "Over"
    #   c.geometry "+0+0"
    # end
    #
    # result_image = result_image.composite(image22) do |c|
    #   c.compose "Over"
    #   c.geometry "+0+#{image11.height}"
    # end
    #
    # # Сохраняем результат во временный файл
    # output_path = Rails.root.join("tmp", "combined_image.jpg")
    # result_image.write(output_path)
    #
    # # Отправляем результат клиенту
    # send_file output_path, type: 'image/jpeg', disposition: 'inline'
    #
    # image11.close
    # image22.close
    #File.delete(output_path) if File.exist?(output_path)

  end
end