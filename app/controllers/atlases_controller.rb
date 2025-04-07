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

  def update # полностью перестроить атлас в заданном типе
    raise "not authorized" unless @current_user
    @atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id] unless @atlas

    case params[:type]
    when "inline"
      update_inline
    when "bookshelf"
      update_bookshelf
    when "skyline"
      update_skyline
    else
      raise "op_type is unexpected"
    end

    # atlas_url = url_for(atlas.atlas_img)
    #
    # atlas_img = MiniMagick::Image.open(atlas_url)
    # atlas_img.colorspace "sRGB"
    # atlas_img.alpha "on"
    # atlas_img.background "none"
    #
    # height = atlas_img.height
    # width = atlas_img.width
    #
    # atlas.sprites.each do |sprite|
    #   sprite_img = MiniMagick::Image.open(url_for(sprite.sprite_img))
    #   height = [height, sprite_img.height].max
    #   width = width + sprite_img.width
    #
    #
    #   atlas_img.combine_options do |c|
    #     c.background "none"
    #     c.extent "#{width}x#{height}"
    #   end
    #
    #   atlas_img.colorspace "sRGB"
    #   atlas_img.alpha "on"
    #
    #   atlas_img = atlas_img.composite(sprite_img) do |c|
    #         c.compose "Over"
    #         c.geometry "+#{width - sprite_img.width}+0"
    #         c.alpha "on"
    #         c.colorspace "sRGB"
    #   end
    # end
    #
    #
    # atlas.atlas_img.attach(
    #   io: File.open(atlas_img.path),
    #   filename: atlas.title + ".png",
    #   content_type: 'image/png',
    # )
  rescue => err
    render json: { error: "Error in update in atlas_controller: " + err.message }
  end

  def create
    raise "user not authorized" unless @current_user

    atlas = @current_user.atlases.create(title: params[:title], coords: { type: "inline", coords: [] })
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

  #-------------------------#
  # UPDATE METHODS

  #
  def update_inline
    raise "no atlas" unless @atlas

    # new coords data
    coords = [] # coord = { id, start_width, width, height }

    atlas_url = url_for(@atlas.atlas_img)

    atlas_img = MiniMagick::Image.open(atlas_url)
    atlas_img.colorspace "sRGB"
    atlas_img.alpha "on"
    atlas_img.background "none"

    # height = atlas_img.height
    # width = atlas_img.width

    height = 0
    width = 0

    atlas_img.combine_options do |c|
      c.background "none"
      c.extent "#{1}x#{1}"
    end

    @atlas.sprites.each do |sprite|
      sprite_img = MiniMagick::Image.open(url_for(sprite.sprite_img))
      sprite_height = sprite_img.height
      sprite_width = sprite_img.width

      coords.push({
        id: sprite.id,
        start_width: width,
        width: sprite_width,
        height: sprite_height
      })

      height = [height, sprite_height].max
      width = width + sprite_width

      atlas_img.combine_options do |c|
        c.background "none"
        c.extent "#{width}x#{height}"
      end

      atlas_img.colorspace "sRGB"
      atlas_img.alpha "on"

      atlas_img = atlas_img.composite(sprite_img) do |c|
        c.compose "Over"
        c.geometry "+#{width - sprite_width}+0"
        c.alpha "on"
        c.colorspace "sRGB"
      end

    end


    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "inline", coords: coords }
    @atlas.save

    render json: { message: "Atlas successfully updated.", atlas_img: atlas_img.path }


  rescue => err
    render json: { error: "error in update_inline: " + err.message }
  end

  def update_bookshelf
    # надо хранить дополнительную инфу в коордс в зависимости от используемого метода упаковки
    # чтобы в будущем уметь удалять и добавлять картинки открывая уже обработанный атлас
    # нужно не откладывать на потом динамическое добавление и удаление каринок из атласа а сразу  сделать всё для того чтобы всё работало


    raise "no atlas" unless @atlas

    coords = []  # coord = { img_id, start_height, start_width, height, width }
    shelves = [] # shelf = { start_height, height, width } # need to sort by shelf height

    atlas_url = url_for(@atlas.atlas_img)

    atlas_img = MiniMagick::Image.open(atlas_url)
    atlas_img.colorspace "sRGB"
    atlas_img.alpha "on"
    atlas_img.background "none"

    atlas_height = 0
    atlas_width = 0

    atlas_img.combine_options do |c|
      c.background "none"
      c.extent "#{1}x#{1}"
    end

    @atlas.sprites.each do |sprite|
      sprite_img = MiniMagick::Image.open(url_for(sprite.sprite_img))
      sprite_height = sprite_img.height
      sprite_width = sprite_img.width

      # try to find shelf
      shelf = nil
      shelves.each do |sh|
        if sh[:height] > sprite_height && sprite_height.to_f/sh[:height] > 0.7
          shelf = sh
          break
        end
      end

      if shelf == nil
        # create new shelf
        shelf = {
          start_height: atlas_height,
          height: sprite_height,
          width: sprite_width,
        }
        shelves.push(shelf)

        coord = {
          id: sprite.id,
          start_height: shelf[:start_height],
          start_width: 0,
          height: sprite_height,
          width: sprite_width
        }
        coords.push(coord)

        atlas_height += shelf[:height]
        if atlas_width < shelf[:width]
          atlas_width = shelf[:width]
        end

        atlas_img.combine_options do |c|
          c.background "none"
          c.extent "#{atlas_width}x#{atlas_height}"
        end

        atlas_img.colorspace "sRGB"
        atlas_img.alpha "on"

        atlas_img = atlas_img.composite(sprite_img) do |c|
          c.compose "Over"
          c.geometry "+0+#{shelf[:start_height]}"
          c.alpha "on"
          c.colorspace "sRGB"
        end


      else # placing sprite on existing shelf
        coord = {
          id: sprite.id,
          start_height: shelf[:start_height],
          start_width: shelf[:width],
          height: sprite_height,
          width: sprite_width
        }
        coords.push(coord)

        shelf[:width] += sprite_width
        if shelf[:width] > atlas_width
          atlas_width = shelf[:width]

          atlas_img.combine_options do |c|
            c.background "none"
            c.extent "#{atlas_width}x#{atlas_height}"
          end
        end

        atlas_img.colorspace "sRGB"
        atlas_img.alpha "on"
        atlas_img = atlas_img.composite(sprite_img) do |c|
          c.compose "Over"
          c.geometry "+#{coord[:start_width]}+#{coord[:start_height]}"
          c.alpha "on"
          c.colorspace "sRGB"
        end

      end

    end


    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "bookshelf", coords: coords, shelves: shelves }
    @atlas.save

    render json: { message: "Atlas successfully updated.", atlas_img: atlas_img.path }

  rescue => err
    render json: { error: "error in update_bookshelf: " + err.message }
  end

  def update_skyline

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