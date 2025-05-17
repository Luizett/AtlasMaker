require 'mini_magick'

class AtlasesController < ApplicationController

  before_action :authenticate_request

  include SkylineAlgo

  def index
    raise "not authorized" unless @current_user
    atlasess = []
    @current_user.atlases.each do |atlas|
      #size = atlas.atlas_img.metadata.to_s
      atlasess.push({
                      atlas_id: atlas.id,
                      title: atlas.title,
                      #  updated_at: atlas.updated_at.strftime('%d-%m-%Y %H:%M'),
                      updated_at: atlas.updated_at,
                      atlas_img: atlas.atlas_img.attached? ? url_for(atlas.atlas_img) : nil,
                      size: atlas.atlas_img
                    })
    end
    raise "atlases empty" unless atlasess

    atlasess.sort_by! { |atl| atl[:updated_at] }.reverse!

    render json: { atlases: atlasess }
  rescue => err
    render json: { errors: err }
  end

  def update # полностью перестроить атлас в заданном типе
    raise "not authorized" unless @current_user
    @atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id] unless @atlas

    ActionCable.server.broadcast("loading_#{@atlas.id}", {percent: "10"})

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

    ActionCable.server.broadcast("loading_#{@atlas.id}", { percent: "100" })

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
    render json: { message: "Atlas successfully updated.", atlas_img: url_for(@atlas.atlas_img) }


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
        if sh[:height] >= sprite_height && sprite_height.to_f/sh[:height] > 0.7
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
    render json: { message: "Atlas successfully updated.", atlas_img: url_for(@atlas.atlas_img) }

  rescue => err
    render json: { error: "error in update_bookshelf: " + err.message }
  end

  def update_skyline

    skylines = [] # skyline = { start_height, start_width, end_width, width}
    coords = [] # coord = { img_id, start_height, start_width, height, width }
    widespaces = [] # wides = { start_height, start_width, height, width, square }  # must be sorted by square,
                                                                                    #  when find smaller spacethat fit search must be stoppes

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_img.colorspace "sRGB"
    atlas_img.alpha "on"
    atlas_img.background "none"

    atlas_height = 1
    atlas_width = 1

    atlas_img.combine_options do |c|
      c.background "none"
      c.extent "#{1}x#{1}"
    end

    @atlas.sprites.each do |sprite|
      sprite_img = MiniMagick::Image.open(url_for(sprite.sprite_img))
      sprite_height = sprite_img.height
      sprite_width = sprite_img.width

      widespace = nil
      # пробуем найти место в widespaces
      widespaces.each do |widesp|
        if sprite_height <= widesp[:height] && sprite_width <= widesp[:width]
          widespace = widesp
          break
        end
      end

      if widespace
        # вставляем спрайт в найденное место
        coord = {
          id: sprite.id,
          start_height: widespace[:start_height],
          start_width: widespace[:start_width],
          height: sprite_height,
          width: sprite_width
        }
        coords.push(coord)

        atlas_img = atlas_img.composite(sprite_img) do |c|
          c.compose "Over"
          c.geometry "+#{coord[:start_width]}+#{coord[:start_height]}"
          c.alpha "on"
          c.colorspace "sRGB"
        end

        # заменяем старое widespace на новые образовавшиеся
        ws1 = {
          start_width: widespace[:start_width] + coord[:width],
          start_height: widespace[:start_height],
          width: widespace[:width] - coord[:width]
        }
        ws2 = {
          start_width: widespace[:start_width],
          start_height: widespace[:start_height] + coord[:height],
          height: widespace[:height] - coord[:height]
        }

        # проверяем какой разрез сделать сравнивая соотношения сторон (надо сделать одну из областей как можно больше по площади)
        if coord[:width] / widespace[:width].to_d < coord[:height] / widespace[:height].to_f
          ws1[:height] = widespace[:height]
          ws2[:width] =  coord[:width]
        else
          ws1[:height] = coord[:height]
          ws2[:width] =  widespace[:width]
        end
        ws1[:square] = ws1[:height] * ws1[:width]
        ws2[:square] = ws2[:height] * ws2[:width]

        widespaces.delete(widespace)
        widespaces.push(ws1) if ws1[:square] > 0
        widespaces.push(ws2) if ws2[:square] > 0

        widespaces = widespaces.sort_by { |w| w[:square] }

      else # если widespace не найден то переходим к основному алгоритму со skylines

        # если нарушено правило 3:4 или если нет подходящих линий раширяем спрайт вправо
        # подходящая линия = линия такой же длины или больше или же меньше но с местом достаточным для размещения

        skyline = choose_skyline(skylines, sprite_width)
        skyline = skyline.symbolize_keys if skyline.respond_to?(:symbolize_keys)
        ratio = atlas_height / atlas_width.to_f
        if  ratio > 0.75 || !skyline
          # добавляем спрайт справа

          # создаём новый горизонт
          skyline = {
            start_height: sprite_height,
            start_width: atlas_width,
            end_width: atlas_width + sprite_width,
            width: sprite_width
          }
          skylines.push(skyline)

          # добавляем координаты
          coord = {
            id: sprite.id,
            start_height: 0,
            start_width: skyline[:start_width],
            height: sprite_height,
            width: sprite_width
          }
          coords.push(coord)

          # изменяем размер атласа
          atlas_width += sprite_width
          atlas_height = sprite_height if atlas_height < sprite_height
          atlas_img.combine_options do |c|
            c.background "none"
            c.extent "#{atlas_width}x#{atlas_height}"
          end

          # вставляем спрайт в атлас по координатам
          atlas_img = atlas_img.composite(sprite_img) do |c|
            c.compose "Over"
            c.geometry "+#{coord[:start_width]}+#{coord[:start_height]}"
            c.alpha "on"
            c.colorspace "sRGB"
          end

        else
          # вставляем спрайт на найденный горизонт
          coord = {
            id: sprite.id,
            start_height: skyline[:start_height],
            start_width: skyline[:start_width],
            height: sprite_height,
            width: sprite_width
          }
          coords.push(coord)

          # изменяем размер атласа при необходимости
          if atlas_height <  sprite_height + coord[:start_height]
            atlas_height = sprite_height + coord[:start_height]
            atlas_img.combine_options do |c|
              c.background "none"
              c.extent "#{atlas_width}x#{atlas_height}"
            end
          end

          atlas_img = atlas_img.composite(sprite_img) do |c|
            c.compose "Over"
            c.geometry "+#{coord[:start_width]}+#{coord[:start_height]}"
            c.alpha "on"
            c.colorspace "sRGB"
          end

          # меняем горизонт на актуальный
          skyline[:width] = sprite_width
          skyline[:end_width] = skyline[:start_width] + sprite_width

          # удаление занятых линий ( и добавление новых widespace при наличии)
          # skylines = skylines.delete_if { |s| skyline[:start_width] <= s[:start_width] && s[:end_width] <= skyline[:end_width] }
          skylines = skylines.delete_if do |s|
            if skyline[:start_width] <= s[:start_width] && s[:end_width] <= skyline[:end_width]
              if s[:start_height] != skyline[:start_height]
                new_widespace = {
                  start_height: s[:start_height],
                  start_width: s[:start_width],
                  width: s[:width],
                  height: skyline[:start_height] - s[:start_height]
                }
                new_widespace[:square] = new_widespace[:width] * new_widespace[:height]
                widespaces.push(new_widespace)
              end
              true
            else false
            end
          end
          skyline[:start_height] += sprite_height
          skylines.insert(0, skyline)
          skylines = skylines.sort_by{ |s|  [s[:start_width], s[:end_width]] }

          # изменение затронутой частично линии если она есть (и добавление нового widespace)
          next_skyline = skylines[skylines.find_index(skyline)+ 1]
          if next_skyline && next_skyline[:start_width] < skyline[:end_width]

            if next_skyline[:start_height] != coord[:start_height]
              new_widespace = {
                start_height: +next_skyline[:start_height],
                start_width: +next_skyline[:start_width],
                height: coord[:start_height] - next_skyline[:start_height],
                width: skyline[:end_width] - next_skyline[:start_width]
              }
              new_widespace[:square] = new_widespace[:width] * new_widespace[:height]
              widespaces.push(new_widespace)
            end

            next_skyline[:start_width] = skyline[:end_width]
            next_skyline[:width] = next_skyline[:end_width] - next_skyline[:start_width]

          end
          widespaces = widespaces.sort_by { |w| w[:square] }
        end

      end

    end


    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "skyline", coords: coords, skylines: skylines, widespaces: widespaces }
    @atlas.save

    render json: { message: "Atlas successfully updated.", atlas_img: url_for(@atlas.atlas_img) }
  end




end