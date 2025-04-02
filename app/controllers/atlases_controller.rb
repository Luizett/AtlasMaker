require 'mini_magick'

class AtlasesController < ApplicationController

  before_action :authenticate_request

  # TODO создать здесь обработчики событий с атласами: добавление удаление
  # метод генерации изображения атласа по присоединённым изображениям (по вызову)
  # сначала просто склейка изображений подряд как в тестовой пробе
  # затем с использованием алгоритма какого-нибудь (полки)
  # заглушка под второй алгоритм
  # второй алгоритм (гильятина)

  def index # todo sort by recent update before send
    raise "not authorized" unless @current_user
    atlasess = []
    @current_user.atlases.each do |atlas|
      #size = atlas.atlas_img.metadata.to_s
      atlasess.push({
                      atlas_id: atlas.id,
                      title: atlas.title,
                      updated_at: atlas.updated_at.strftime('%d-%m-%Y %H:%M'),
                      atlas_img: atlas.atlas_img.attached? ? url_for(atlas.atlas_img) : nil,
                      #atlas_size: size
                    })
    end
    raise "atlases empty" unless atlasess
    render json: { atlases: atlasess }
  rescue => err
    render json: { errors: err }
  end

  def update
    raise "not authorized" unless @current_user
    atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id] unless atlas

    atlas_url = url_for(atlas.atlas_img)

    atlas_img = MiniMagick::Image.open(atlas_url)
    atlas_img.colorspace "sRGB"
    atlas_img.alpha "on"
    atlas_img.background "none"

    height = atlas_img.height
    width = atlas_img.width

    atlas.sprites.each do |sprite|
      sprite_img = MiniMagick::Image.open(url_for(sprite.sprite_img))
      height = [height, sprite_img.height].max
      width = width + sprite_img.width


      atlas_img.combine_options do |c|
        c.background "none"
        c.extent "#{width}x#{height}"
      end

      atlas_img.colorspace "sRGB"
      atlas_img.alpha "on"

      atlas_img = atlas_img.composite(sprite_img) do |c|
            c.compose "Over"
            c.geometry "+#{width - sprite_img.width}+0"
            c.alpha "on"
            c.colorspace "sRGB"
      end
    end


    atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: atlas.title + ".png",
      content_type: 'image/png',
    )

  end

  def create
    raise "user not authorized" unless @current_user

    atlas = @current_user.atlases.create(title: params[:title])
    raise "Something went wrong while creating new atlas" unless atlas

    MiniMagick.convert do |convert|
      convert.merge! ["-size", "1x1", "canvas:transparent", "PNG32:public/images/empty.png"]
    end

    atlas.atlas_img.attach(
      io: File.open(Rails.root.join('public', 'images', 'empty.png')),
      filename: atlas.title + '.png',
      content_type: 'image/png'
    )
    raise "Something went wrong while attaching image to atlas" unless atlas.atlas_img.attached?

    atlas.save
    render json: {
      atlas_id: atlas.id,
      title: atlas.title,
      updated_at: atlas.updated_at.strftime('%d-%m-%Y %H:%M'),
      atlas_img: atlas.atlas_img.attached? ? url_for(atlas.atlas_img) : nil
    }

  rescue => err
    render json: { errors: err.message }
  end

  def show
    raise "not authorized" unless @current_user

    atlas = @current_user.atlases.find(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id] unless atlas

    render json: {
        atlas_id: atlas.id,
        title: atlas.title,
        atlas_img: url_for(atlas.atlas_img)
    }
  rescue => err
    render json: { errors: "Error in atlases_controller show: " + err.message }
  end

  def delete

    raise "not authorized" unless @current_user
    raise "no required params" unless params
    raise "no required params" unless params[:atlas_id]

    atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "cant find atlas with id " unless atlas

    if atlas && atlas.destroy
      render json: { message: "Atlas successfully deleted." }
    else
      render json: { errors: "Something went wrong while deleting atlas" }
    end
  rescue => err
    render json: { errors: err}
  end

  # def create
  #   file1 = params[:img1]
  #   file2 = params[:img2]
  #
  #
  #   image11 = MiniMagick::Image.open(file1.file.path)
  #   image22 = MiniMagick::Image.open(file2.file.path)
  #
  #   width = [image11.width, image22.width].max
  #   height = image11.height + image22.height
  #
  #   # Создаем новое изображение с размерами, достаточными для склейки
  #   result_image = MiniMagick::Image.new("result.jpg") do |img|
  #     img.combine_options do |c|
  #       c.size "#{width}x#{height}"
  #       c.gravity "north"
  #       c.background "white"
  #       c.extent "#{width}x#{height}"
  #     end
  #   end
  #
  #   # Склеиваем изображения вертикально
  #   result_image = result_image.composite(image1) do |c|
  #     c.compose "Over"
  #     c.geometry "+0+0"
  #   end
  #
  #   result_image = result_image.composite(image2) do |c|
  #     c.compose "Over"
  #     c.geometry "+0+#{image1.height}"
  #   end
  #
  #   # Сохраняем результат во временный файл
  #   output_path = Rails.root.join("tmp", "combined_image.jpg")
  #   result_image.write(output_path)
  #
  #   # Отправляем результат клиенту
  #   send_file output_path, type: 'image/jpeg', disposition: 'inline'
  #
  #   file1.close
  #   file2.close
  #   File.delete(output_path) if File.exist?(output_path)
  # end
end