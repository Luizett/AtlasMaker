require 'mini_magick'
class SpriteController < ApplicationController
  before_action :authenticate_request
  include SkylineAlgo

  def show_all
    raise "user not auth " unless @current_user
    atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id].to_s unless atlas

    sprites = []
    atlas.sprites.each do |sprite|
      sprites.push({
                     sprite_id: sprite.id,
                     filename: sprite.sprite_img.filename,
                     sprite_img: url_for(sprite.sprite_img)
      })
    end
    render json: { sprites: sprites }
  rescue => err
    render json: { errors: "Error in show_all: " + err.message }
  end

  def create
    raise "user not auth " unless @current_user
    @atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id].to_s unless @atlas
    @sprite = @atlas.sprites.create
    raise "Something went wrong while creating sprite" unless @sprite

    @sprite.sprite_img.attach(params[:img])
    raise "error while attaching sprite" unless @sprite.sprite_img.attached?

    if @sprite.save
      case @atlas.coords["type"]
      when 'inline'
        create_inline
      when 'bookshelf'
        create_bookshelf
      when 'skyline'
        create_skyline
      else
        raise "Unexpected atlas type: " + @atlas.coords["type"]
      end

      render json: {
        sprite: {
          sprite_id: @sprite.id,
          filename: @sprite.sprite_img.filename,
          sprite_img: url_for(@sprite.sprite_img)
        },
        atlas_img: url_for(@atlas.atlas_img)
      }
    else
      raise "error while saving sprite"
    end

  rescue => err
    render json: { error: "Error in create in sprite_controller: " + err.message }
  end

  def delete
    raise "user not auth " unless @current_user
    @atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id].to_s unless @atlas
    @sprite = @atlas.sprites.find_by_id(params[:sprite_id])
    raise "can't find sprite with id: " + params[:sprite_id].to_s unless @sprite

    case @atlas.coords["type"]
    when 'inline'
      delete_inline
    when 'bookshelf'
      delete_bookshelf
    when 'skyline'
      delete_skyline
    else
      raise "Unexpected atlas type: " + @atlas.coords["type"]
    end

    if @sprite.destroy
      render json: { message: 'sprite successfully deleted', atlas_img: url_for(@atlas.atlas_img) }
    else
      raise "Something went wrong while deleting sprite"
    end
  rescue => err
    render json: { error: "Error in delete in sprite_controller: " + err.message }
  end


private

  def create_inline
    coords = @atlas.coords["coords"]

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    sprite_img = MiniMagick::Image.open(url_for(@sprite.sprite_img))
    sprite_width = sprite_img.width
    sprite_height = sprite_img.height

    coord = {
      id: @sprite.id,
      start_width: atlas_width,
      width: sprite_width,
      height: sprite_height
    }
    coords.push(coord)

    atlas_width += sprite_width
    atlas_height = [sprite_height, atlas_height].max

    atlas_img.combine_options do |c|
      c.background "none"
      c.extent "#{atlas_width}x#{atlas_height}"
    end

    atlas_img.colorspace "sRGB"
    atlas_img.alpha "on"

    atlas_img = atlas_img.composite(sprite_img) do |c|
      c.compose "Over"
      c.geometry "+#{coord[:start_width]}+0"
      c.alpha "on"
      c.colorspace "sRGB"
    end

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "inline", coords: coords }
    @atlas.save
  end

  def create_bookshelf

    shelves = @atlas.coords["shelves"]
    coords = @atlas.coords["coords"]

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    sprite_img = MiniMagick::Image.open(url_for(@sprite.sprite_img))
    sprite_width = sprite_img.width
    sprite_height = sprite_img.height

    shelf = shelves.find { |sh| sh["height"] >= sprite_height && sprite_height.to_f/sh["height"] > 0.7}

    if shelf
      # insert to shelf
      coord = {
        id: @sprite.id,
        start_height: shelf["start_height"],
        start_width: shelf["width"],
        height: sprite_height,
        width: sprite_width
      }
      coords.push(coord)

      shelf["width"] += sprite_width
      if shelf["width"] > atlas_width
        atlas_width = shelf["width"]

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

    else
      # create new shelf

      shelf = {
        start_height: atlas_height,
        height: sprite_height,
        width: sprite_width
      }
      shelves.push(shelf)

      coord = {
        id: @sprite.id,
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

    end

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: "image/png"
    )

    @atlas.coords = { type: "bookshelf", coords: coords, shelves: shelves }
    @atlas.save

  end

  def create_skyline

    coords = @atlas.coords["coords"]
    widespaces = @atlas.coords["widespaces"]
    skylines = @atlas.coords["skylines"]

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    sprite_img = MiniMagick::Image.open(url_for(@sprite.sprite_img))
    sprite_width = sprite_img.width
    sprite_height = sprite_img.height


    widespace = nil
    # пробуем найти место в widespaces
    widespaces.each do |widesp|
      if sprite_height <= widesp["height"] && sprite_width <= widesp["width"]
        widespace = widesp
        break
      end
    end

    if widespace
      # вставляем спрайт в найденное место
      coord = {
        "id": @sprite.id,
        "start_height": widespace["start_height"],
        "start_width": widespace["start_width"],
        "height": sprite_height,
        "width": sprite_width
      }.stringify_keys
      coords.push(coord)

      atlas_img = atlas_img.composite(sprite_img) do |c|
        c.compose "Over"
        c.geometry "+#{coord["start_width"]}+#{coord["start_height"]}"
        c.alpha "on"
        c.colorspace "sRGB"
      end

      # заменяем старое widespace на новые образовавшиеся
      ws1 = {
        "start_width": widespace["start_width"] + coord["width"],
        "start_height": widespace["start_height"],
        "width": widespace["width"] - coord["width"]
      }.stringify_keys
      ws2 = {
        "start_width": widespace["start_width"],
        "start_height": widespace["start_height"] + coord["height"],
        "height": widespace["height"] - coord["height"]
      }.stringify_keys

      # проверяем какой разрез сделать сравнивая соотношения сторон (надо сделать одну из областей как можно больше по площади)
      if coord["width"] / widespace["width"].to_d < coord["height"] / widespace["height"].to_f
        ws1["height"] = widespace["height"]
        ws2["width"] =  coord["width"]
      else
        ws1["height"] = coord["height"]
        ws2["width"] =  widespace["width"]
      end
      ws1["square"] = ws1["height"] * ws1["width"]
      ws2["square"] = ws2["height"] * ws2["width"]

      widespaces.delete(widespace)
      widespaces.push(ws1) if ws1["square"] > 0
      widespaces.push(ws2) if ws2["square"] > 0

      widespaces = widespaces.sort_by { |w| w["square"] }

    else # если widespace не найден то переходим к основному алгоритму со skylines

      # если нарушено правило 3:4 или если нет подходящих линий раширяем спрайт вправо
      # подходящая линия = линия такой же длины или больше или же меньше но с местом достаточным для размещения

      skyline = choose_skyline(skylines, sprite_width)
      ratio = atlas_height / atlas_width.to_f
      if  ratio > 0.75 || !skyline
        # добавляем спрайт справа

        # создаём новый горизонт
        skyline = {
          start_height: sprite_height,
          start_width: atlas_width,
          end_width: atlas_width + sprite_width,
          width: sprite_width
        }.stringify_keys
        skylines.push(skyline)

        # добавляем координаты
        coord = {
          id: @sprite.id,
          start_height: 0,
          start_width: skyline["start_width"],
          height: sprite_height,
          width: sprite_width
        }.stringify_keys
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
          c.geometry "+#{coord["start_width"]}+#{coord["start_height"]}"
          c.alpha "on"
          c.colorspace "sRGB"
        end

      else
        # вставляем спрайт на найденный горизонт
        coord = {
          id: @sprite.id,
          start_height: skyline["start_height"],
          start_width: skyline["start_width"],
          height: sprite_height,
          width: sprite_width
        }.stringify_keys
        coords.push(coord)

        # изменяем размер атласа при необходимости
        if atlas_height <  sprite_height + coord["start_height"]
          atlas_height = sprite_height + coord["start_height"]
          atlas_img.combine_options do |c|
            c.background "none"
            c.extent "#{atlas_width}x#{atlas_height}"
          end
        end

        atlas_img = atlas_img.composite(sprite_img) do |c|
          c.compose "Over"
          c.geometry "+#{coord["start_width"]}+#{coord["start_height"]}"
          c.alpha "on"
          c.colorspace "sRGB"
        end

        # меняем горизонт на актуальный
        skyline["width"] = sprite_width
        skyline["end_width"] = skyline["start_width"] + sprite_width

        # удаление занятых линий ( и добавление новых widespace при наличии)
        # skylines = skylines.delete_if { |s| skyline[:start_width] <= s[:start_width] && s[:end_width] <= skyline[:end_width] }
        skylines = skylines.delete_if do |s|
          if skyline["start_width"] <= s["start_width"] && s["end_width"] <= skyline["end_width"]
            if s["start_height"] != skyline["start_height"]
              new_widespace = {
                start_height: s["start_height"],
                start_width: s["start_width"],
                width: s["width"],
                height: skyline["start_height"] - s["start_height"]
              }.stringify_keys
              new_widespace["square"] = new_widespace["width"] * new_widespace["height"]
              widespaces.push(new_widespace)
            end
            true
          else false
          end
        end
        skyline["start_height"] += sprite_height
        skylines.insert(0, skyline)
        skylines = skylines.sort_by{ |s|  [s["start_width"], s["end_width"]] }

        # изменение затронутой частично линии если она есть (и добавление нового widespace)
        next_skyline = skylines[skylines.find_index(skyline)+ 1]
        if next_skyline && next_skyline["start_width"] < skyline["end_width"]

          if next_skyline["start_height"] != coord["start_height"]
            new_widespace = {
              start_height: +next_skyline["start_height"],
              start_width: +next_skyline["start_width"],
              height: coord["start_height"] - next_skyline["start_height"],
              width: skyline["end_width"] - next_skyline["start_width"]
            }.stringify_keys
            new_widespace["square"] = new_widespace["width"] * new_widespace["height"]
            widespaces.push(new_widespace)
          end

          next_skyline["start_width"] = skyline["end_width"]
          next_skyline["width"] = next_skyline["end_width"] - next_skyline["start_width"]

        end
        widespaces = widespaces.sort_by { |w| w["square"] }
      end
    end

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: "image/png"
    )

    @atlas.coords = { type: "skyline", coords: coords, skylines: skylines, widespaces: widespaces }
    @atlas.save
  end


  #=============================#
  # DELETE

  def delete_inline

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    coords = @atlas.coords["coords"]
    coord_ind = coords.find_index { |sprite| sprite["id"] == @sprite.id }
    raise "can't find coord with id: " + @sprite.id unless coord_ind

    coord = coords[coord_ind]

    # проверка что картинка не первая и не последняя
    if coord_ind == 0
      # оставить только правую часть
      next_coord = coords[coord_ind + 1]
      atlas_img.combine_options do |c|
        c.extent "#{atlas_width - next_coord["start_width"]}x#{atlas_height}+#{next_coord["start_width"]}+0"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end

    elsif coord_ind == coords.size - 1
      # оставить только левую часть
      atlas_img.combine_options do |c|
        c.extent "#{atlas_width - coord["width"]}x#{atlas_height}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    else
      next_coord = coords[coord_ind + 1]

      right_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      right_part.combine_options do |c|
        c.extent "#{atlas_width - next_coord["start_width"]}x#{atlas_height}+#{next_coord["start_width"]}+0"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end

      # оставить только левую часть атласа и подогнать атлас под новый размер
      atlas_img.combine_options do |c|
            c.extent "#{coord["start_width"]}x#{atlas_height}"
            c.background "none"
            c.colorspace "sRGB"
            c.alpha "on"
            c.extent "#{atlas_width - coord["width"]}x#{atlas_height}"
      end

      # вставить правую часть
      atlas_img = atlas_img.composite(right_part) do |c|
            c.compose "Over"
            c.geometry "+#{coord["start_width"]}+0"
            c.alpha "on"
            c.colorspace "sRGB"
      end

    end

    # смещение координат в массиве
    (coord_ind+1...coords.size).each do |i|
      coords[i]["start_width"] -= coord["width"]
    end

    coords.delete_at(coord_ind)

    if coord["height"] == atlas_img.height
      # ищем новую высоту атласа
      new_height = 0
      atlas_width = atlas_img.width

      coords.each do |c|
        new_height = [c["height"], new_height].max
      end

      atlas_img.combine_options do |c|
        c.extent "#{atlas_width}x#{new_height}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    end

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "inline", coords: coords }
    @atlas.save

  end

  def delete_bookshelf

    shelves = @atlas.coords["shelves"]
    coords = @atlas.coords["coords"]

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    coord_ind = coords.find_index { |sprite| sprite["id"] == @sprite.id }
    raise "can't find coord with id: " + @sprite.id unless coord_ind
    coord = coords[coord_ind]

    shelf = shelves.find { |sh| sh["start_height"] == coord["start_height"] }
    raise "can't find shelf with start_height: " + coord["start_height"] unless shelf
    next_shelf_start = shelf["start_height"]+shelf["height"]


    upper_shelves_w = atlas_width
    upper_shelves_h = coord["start_height"]
    if upper_shelves_w != 0 && upper_shelves_h != 0
      upper_shelves = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      upper_shelves = upper_shelves.combine_options do |c|
        c.extent "#{upper_shelves_w}x#{upper_shelves_h}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    end

    lower_shelves_w = atlas_width
    lower_shelves_h = atlas_height - next_shelf_start
    if lower_shelves_w != 0 && lower_shelves_h != 0
      lower_shelves = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      lower_shelves = lower_shelves.combine_options do |c|
        c.extent "#{lower_shelves_w}x#{lower_shelves_h}+0+#{next_shelf_start}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    end
    # lower_shelves = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    # #lower_shelves = atlas_img.extent("#{atlas_width}x#{atlas_height - next_shelf_start}+0+#{next_shelf_start}")
    # lower_shelves = lower_shelves.combine_options do |c|
    #   c.extent "#{atlas_width}x#{atlas_height - next_shelf_start}+0+#{next_shelf_start}"
    #   c.background "none"
    #   c.colorspace "sRGB"
    #   c.alpha "on"
    # end
    # lower_shelves_h = lower_shelves.height
    # lower_shelves_w = lower_shelves.width

    shelf_left_part_w = coord["start_width"]
    shelf_left_part_h = shelf["height"]
    if shelf_left_part_w != 0 && shelf_left_part_h != 0
      shelf_left_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      shelf_left_part = shelf_left_part.combine_options do |c|
        c.extent "#{shelf_left_part_w}x#{shelf_left_part_h}+0+#{shelf["start_height"]}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    end

    shelf_right_part_w = shelf["width"] - (coord["start_width"] + coord["width"])
    shelf_right_part_h = shelf["height"]
    if shelf_right_part_w != 0 && shelf_right_part_h != 0
      shelf_right_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      shelf_right_part = shelf_right_part.combine_options do |c|
        c.extent "#{shelf_right_part_w}x#{shelf_right_part_h}+#{coord["start_width"] + coord["width"]}+#{shelf["start_height"]}"
        c.background "none"
        c.colorspace "sRGB"
        c.alpha "on"
      end
    end


    atlas_img.combine_options do |c|
      c.extent "#{1}x#{1}"
      c.background "none"
      c.colorspace "sRGB"
      c.alpha "on"
    end

    shelf["width"] -= coord["width"]

    if shelf["width"] + coord["width"] == atlas_width
      atlas_width = shelves.map{ |s| s["width"] }.max
    end

    if shelf["width"] == 0
      atlas_height -= shelf["height"]
      next_shelf_start -= shelf["height"]
      # смещение координат и полок
      coords.each do |c|
        c["start_height"] -= shelf["height"] if c["start_height"] > shelf["start_height"]
      end
      shelves.each do |s|
        s["start_height"] -= shelf["height"] if s["start_height"] > shelf["start_height"]
      end

    else
      (coord_ind+1...coords.size).each do |i|
        if coords[i]["start_height"] == shelf["start_height"]
          coords[i]["start_width"] -= coord["width"]
        end
      end
    end

    atlas_img.combine_options do |c|
      c.extent "#{atlas_width}x#{atlas_height}"
      c.background "none"
      c.colorspace "sRGB"
      c.alpha "on"
    end
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height

    atlas_img = atlas_img.composite(upper_shelves) do |c|
      c.compose "Over"
      c.geometry "+0+0"
      c.alpha "on"
      c.colorspace "sRGB"
    end if upper_shelves

    atlas_img = atlas_img.composite(shelf_left_part) do |c|
      c.compose "Over"
      c.geometry "+0+#{coord["start_height"]}"
      c.alpha "on"
      c.colorspace "sRGB"
    end if shelf_left_part

    atlas_img = atlas_img.composite(shelf_right_part) do |c|
      c.compose "Over"
      c.geometry "+#{coord["start_width"]}+#{coord["start_height"]}"
      c.alpha "on"
      c.colorspace "sRGB"
    end if shelf_right_part

    atlas_img = atlas_img.composite(lower_shelves) do |c|
      c.compose "Over"
      c.geometry "+0+#{next_shelf_start}"
      c.alpha "on"
      c.colorspace "sRGB"
    end if lower_shelves

    atlas_height = atlas_img.height
    atlas_width = atlas_img.width

    shelves.delete(shelf) if shelf["width"] == 0
    coords.delete_at(coord_ind)

    # atlas_img = MiniMagick::Image.new(upper_shelves) do |img|
    #   img << shelf_full.path
    #   img << lower_shelves.path
    #   img.append
    # end


    # shelf_full = MiniMagick.convert do |c|
    #   c << shelf_left_part.path
    #   c.append.+
    #   c << shelf_right_part.path
    #   c.call
    # end
    #
    #
    #
    #
    # coords.delete_at(coord_ind)
    #
    # shelf_full_height = shelf_full.height
    # if shelf_full.width == 0
    #   shelf_full_height = 0
    # else
    #   #change height of shelf
    #   if shelf_full_height == coord["height"]
    #     shelf_full_height = 0
    #     coords.each do |c|
    #       if c["start_height"] == shelf["start_height"] && c["height"] > shelf_full_height
    #         shelf_full_height = c["height"]
    #       end
    #     end
    #     if shelf_full_height == 0
    #       shelves.delete(shelf)
    #     end
    #   end
    # end
    #
    # shelf_full.combine_options do |c|
    #     c.extent "#{atlas_width}x#{shelf_full_height}"
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    # end
    #
    # atlas_img = MiniMagick::Tool::Convert.new do |c|
    #   c << upper_shelves.path
    #   c << shelf_full.path
    #   c << lower_shelves.path
    #   c << "append"
    #   c.call
    # end
    #
    # shelf["width"] -= coord["width"]

    # coords change

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: 'image/png'
    )

    @atlas.coords = { type: "bookshelf", coords: coords, shelves: shelves }
    @atlas.save

    # raise 'my error!'

    # # взять полку справа от удаляемого
    # shelf_right_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    # shelf_right_part_start = coord["start_width"] + coord["width"]
    # shelf_right_part.combine_options do |c|
    #   c.extent "#{shelf["width"] - shelf_right_part_start}x#{shelf["height"]}+#{shelf_right_part_start}+#{shelf["start_height"]}"
    #   c.background "none"
    #   c.colorspace "sRGB"
    #   c.alpha "on"
    # end
    #
    # x1 = coord["start_width"]
    # y1 = coord["start_height"]
    # x2 = shelf["width"]     # ширина области = конечная X - начальная X
    # y2 = y1 + shelf["height"]
    # # закрасить область полки начиная с удаляемого пустотой
    # atlas_img.combine_options do |c|
    #   c.background "none"
    #   c.colorspace "sRGB"
    #   c.alpha "on"
    #   c.fill "none"
    #   c.draw "rectangle #{x1},#{y1} #{x2},#{y2}"
    # end
    #
    # atlas_img.write "./atlas_img.png"
    #
    # @atlas.atlas_img.attach(
    #   io: File.open(atlas_img.path),
    #   filename: @atlas.title + ".png",
    #   content_type: 'image/png'
    # )

    #
    #
    # # вставить на это место правую часть полки
    # atlas_img = atlas_img.composite(shelf_right_part) do |c|
    #   c.compose "Over"
    #   c.geometry "+#{coord["start_width"]}+#{coord["start_height"]}"
    #   c.alpha "on"
    #   c.colorspace "sRGB"
    # end
    #
    # shelf["width"] -= coord["width"]
    #
    # # настройка актуальной ширины атласа
    # if shelf["width"] + coord["width"] == atlas_width
    #   atlas_width = shelves.map{ |s| s["width"] }.max
    #   atlas_img.combine_options do |c|
    #     c.extent "#{atlas_width}x#{atlas_height}"
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    #   end
    # end
    #
    # if shelf["width"] == 0
    #   # полка пуста, надо удалить её из массива, сдвинуть остальные полки и изменить размер атласа
    #
    #   # то что было под полкой
    #   shelf_lowers = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    #   shelf_lowers_start_height = shelf["start_height"] + shelf["height"]
    #   shelf_lowers = shelf_lowers.combine_options do |c|
    #     c.extent "#{atlas_width}x#{atlas_height - shelf_lowers_start_height}+0+#{shelf_lowers_start_height}"
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    #   end
    #
    #   h = shelf_lowers.height
    #   w = shelf_lowers.width
    #
    #   # то что было над полкой + свободное пространство
    #   atlas_img.combine_options do |c|
    #     c.extent "#{atlas_width}x#{shelf["start_height"]}+0+0"
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    #   end
    #
    #   atlas_height -= shelf["height"]
    #   atlas_img.combine_options do |c|
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    #     c.extent "#{atlas_width}x#{atlas_height}+0+0"
    #   end
    #
    #   atlas_width = atlas_img.width
    #   atlas_height = atlas_img.height
    #
    #   atlas_img = atlas_img.composite(shelf_lowers) do |c|
    #     c.compose "Over"
    #     c.geometry "+#0+#{shelf["start_height"]}"
    #     c.alpha "on"
    #     c.colorspace "sRGB"
    #   end
    #   atlas_width = atlas_img.width
    #   atlas_height = atlas_img.height
    #   shelves.delete(shelf)
    # else
    #   # если полка не пуста надо переназначит координаты каринок на ней
    #   (coord_ind+1...coords.size).each do |i|
    #     if coords[i]["start_height"] == shelf["start_height"]
    #       coords[i]["start_width"] -= coord["width"]
    #     end
    #   end
    #
    # end
    #
    # coords.delete_at(coord_ind)
    #
    # # взять полку справа от удаляемого
    # # закрасить область полки начиная с удаляемого пустотой
    # # вставить на это место часть полки
    # # удалить полку если полка пуста
    # # изменить размер атласа если надо
    #
    # @atlas.atlas_img.attach(
    #   io: File.open(atlas_img.path),
    #   filename: @atlas.title + ".png",
    #   content_type: 'image/png'
    # )
    #
    # @atlas.coords = { type: "bookshelf", coords: coords, shelves: shelves }
    # @atlas.save
  end

  def delete_skyline
    coords = @atlas.coords["coords"]
    coord_ind = coords.find_index { |sprite| sprite["id"] == @sprite.id }
    raise "can't find coord with id: " + @sprite.id unless coord_ind
    coord = coords[coord_ind]

    widespaces = @atlas.coords["widespaces"]
    skylines = @atlas.coords["skylines"]

    atlas_img = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    atlas_width = atlas_img.width
    atlas_height = atlas_img.height


    coord_skyline = skylines.find { |s|
      s["start_height"] == coord["start_height"] + coord["height"] &&
      coord["start_width"] <= s["start_width"] &&
      s["end_width"] <= coord["start_width"] + coord["width"]
    }
    if coord_skyline # если есть горизонт принадлежащий спрайту
      coord_skyline["start_height"] -= coord["height"]

      # проверка на области скрытые под другими спрайтами
      if coord_skyline["width"] != coord["width"]
        if coord_skyline["start_width"] == coord["start_width"]
          new_widespace = {
            start_height: coord["start_height"],
            start_width: coord["start_width"] + coord["width"],
            height: coord["height"],
            width: coord["width"] - coord_skyline["width"],
            square: coord["height"] * (coord["width"] - coord_skyline["width"]),
          }.stringify_keys
        else
          new_widespace = {
            start_height: coord["start_height"],
            start_width: coord["start_width"],
            height: coord["height"],
            width: coord["width"] - coord_skyline["width"],
            square: coord["height"] * (coord["width"] - coord_skyline["width"]),
          }.stringify_keys
        end
        widespaces.push new_widespace
        widespaces = widespaces.sort_by { |w| w["square"] }
      end


      if coord_skyline["start_height"] == 0 && coord_skyline["end_width"] == atlas_width
        skylines.delete(coord_skyline)
      end

      # mask = MiniMagick::Image.open(url_for(@atlas.atlas_img)) do |c|
      #   c.fill "black" # Всё, что чёрное — останется (непрозрачное)
      #   c.draw "rectangle 0,0 #{atlas_width},#{atlas_height}" # Заливаем весь фон чёрным
      #   c.fill "white" # Белый цвет = прозрачность
      #   c.draw "rectangle 0,0 50,50" # Координаты прозрачного прямоугольника (x1,y1 x2,y2)
      # end
      # mask.alpha("off")

      #      mask = MiniMagick::Image.open(url_for(@atlas.atlas_img))
      # mask = atlas_img.clone
      # mask.alpha "extract"
      # mask.combine_options do |c|
      #   c.fill "black"
      #   #c.draw "rectangle 50,50 100,100" # ← область, которая станет прозрачной
      #   c.draw "rectangle #{coord["start_width"]},#{coord["start_height"]} #{coord["start_width"]+coord["width"]},#{coord["start_height"] + coord["height"]}"
      # end
      #
      #
      # atlas_img.alpha('set')
      # atlas_img = atlas_img.composite(mask) do |c|
      #   c.compose "CopyOpacity" # Используем маску для управления прозрачностью
      # end

      #c.compose "DstIn"  # Режим композиции: оставить только пересечение (прозрачность маски применяется)
      # atlas_img.combine_options do |c|
      #   c.alpha "set"
      #   c.fill "transparent"   # Прозрачный цвет
      #   c.draw "rectangle #{coord["start_width"]},#{coord["start_height"]} #{coord["start_width"]+coord["width"]},#{coord["start_height"] + coord["height"]}"
      # end

      # проверяем не надо ли изменить габариты атласа
      if coord["start_height"] + coord["height"] == atlas_height
        atlas_height = skylines.max_by { |s| s["start_height"] }["start_height"]
      end

      if coord["start_width"] + coord["width"] == atlas_width
        atlas_width = skylines.max_by { |s| s["end_width"] }["end_width"]
      end

      # atlas_img.combine_options do |c|
      #   c.extent "#{atlas_width}x#{atlas_height}"
      #   c.background "none"
      #   c.colorspace "sRGB"
      #   c.alpha "on"
      # end


    else # если спрайт полностью внутренний

      new_widespace = {
        start_height: coord["start_height"],
        start_width: coord["start_width"],
        height: coord["height"],
        width: coord["width"],
        square: -1,
      }.stringify_keys

      # поиск доступных для сливания областей (равны или длины или ширины и соприкасаются)

      # массив флагов против лишних проверок (чтобы при нахождении одной из примыкающих сторон проверять только наличие противоположной к ней )
      sides = { left: true, right: true, up: true, down: true}
      widespaces.delete_if do |w|
        if w["height"] == new_widespace["height"] && w["start_height"] == new_widespace["start_height"]
          if sides[:right] && w["start_width"] == new_widespace["start_width"] + new_widespace["width"] # пространство примыкает справа
            sides[:right]= false
          elsif sides[:left] && new_widespace["start_width"] == w["start_width"] + w["width"] # пространство примыкает слева
            new_widespace["start_width"] = w["start_width"]
            sides[:left] = false
          end
          new_widespace["width"] += w["width"]
           true
        elsif w["width"] == new_widespace["width"] && w["start_width"] == new_widespace["start_width"]
          if sides[:down] && w["start_height"] == new_widespace["start_height"] + new_widespace["height"] # пространство примыкает снизу
            sides[:down] = false
          elsif sides[:up] && new_widespace["start_height"] == w["start_height"] + w["height"] # пространство примыкает сверху
            new_widespace["start_height"] = w["start_height"]
            sides[:up] = false
          end
          new_widespace["height"] += w["height"]
           true
        else
          false
        end
      end
      # (0..widespaces.size).each do |i|
      #   w = widespaces[i]
      #   if w["height"] == new_widespace["height"] && w["start_height"] == new_widespace["start_height"]
      #     if sides[:right] && w["start_width"] == new_widespace["start_width"] + new_widespace["width"] # пространство примыкает справа
      #       sides[:right]= false
      #     elsif sides[:left] && new_widespace["start_width"] == w["start_width"] + w["width"] # пространство примыкает слева
      #       new_widespace["start_width"] = w["start_width"]
      #       sides[:left] = false
      #     end
      #     new_widespace["width"] += w["width"]
      #     widespaces.delete w
      #
      #   elsif w["width"] == new_widespace["width"] && w["start_width"] == new_widespace["start_width"]
      #     if sides[:up] && w["start_height"] == new_widespace["start_height"] + new_widespace["height"] # пространство примыкает сверху
      #       new_widespace["start_height"] = w["start_height"]
      #       sides[:up] = false
      #     elsif sides[:down] && new_widespace["start_height"] == w["start_height"] + w["height"] # пространство примыкает снизу
      #       sides[:down] = false
      #     end
      #     new_widespace["height"] += w["height"]
      #     widespaces.delete w
      #   end
      # end
      new_widespace["square"] = new_widespace["width"] * new_widespace["height"]
      widespaces.push new_widespace
      widespaces = widespaces.sort_by { |w| w["square"] }

      # atlas_img.combine_options do |c|
      #   c.alpha "set"
      #   c.fill "transparent"          # Прозрачный цвет
      #   c.draw "rectangle #{coord["start_width"]},#{coord["start_height"]} #{coord["start_width"]+coord["width"]},#{coord["start_height"] + coord["height"]}"
      # end

    end

    #mask = atlas_img.clone
    mask = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    mask.alpha "extract"
    mask.combine_options do |c|
      c.fill "black"
      #c.draw "rectangle 50,50 100,100" # ← область, которая станет прозрачной
      c.draw "rectangle #{coord["start_width"]},#{coord["start_height"]} #{coord["start_width"]+coord["width"]},#{coord["start_height"] + coord["height"]}"
    end


    atlas_img.alpha('set')
    atlas_img = atlas_img.composite(mask) do |c|
      c.compose "CopyOpacity" # Используем маску для управления прозрачностью
    end

    atlas_img.combine_options do |c|
      c.extent "#{atlas_width}x#{atlas_height}"
      c.background "none"
      c.colorspace "sRGB"
      c.alpha "on"
    end

    # atlas_img.combine_options do |c|
    #   c.fill "none"          # Прозрачный цвет
    #   c.draw "rectangle #{coord["start_width"]},#{coord["start_height"]} #{coord["start_width"]+coord["width"]},#{coord["start_height"] + coord["height"]}"
    # end
    #
    # atlas_img.combine_options do |c|
    #   c.extent "#{atlas_width}x#{atlas_height}"
    #   c.background "none"
    #   c.colorspace "sRGB"
    #   c.alpha "on"
    # end

    coords.delete(coord)

    @atlas.atlas_img.attach(
      io: File.open(atlas_img.path),
      filename: @atlas.title + ".png",
      content_type: "image/png"
    )

    @atlas.coords = { type: "skyline", coords: coords, skylines: skylines, widespaces: widespaces }
    @atlas.save



  end

end
