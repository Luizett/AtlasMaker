require 'mini_magick'

class SpriteController < ApplicationController
  before_action :authenticate_request

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

  def create # todo create for inline, bookshelf and skyline atlases
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
  end

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

    # if coord["start_width"] != 0 && shelf["height"] != 0
    #   shelf_left_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    #   shelf_left_part = shelf_left_part.combine_options do |c|
    #     c.extent "#{coord["start_width"]}x#{shelf["height"]}+0+#{shelf["start_height"]}"
    #     c.background "none"
    #     c.colorspace "sRGB"
    #     c.alpha "on"
    #     end
    #   shelf_left_part_h = shelf_left_part.height
    #   shelf_left_part_w = shelf_left_part.width
    # end
    #    shelf_left_part = atlas_img.extent("#{coord["start_width"]}x#{shelf["height"]}+0+#{shelf["start_height"]}")

    # shelf_right_part = MiniMagick::Image.open(url_for(@atlas.atlas_img))
    # shelf_right_part = shelf_right_part.combine_options do |c|
    #   c.extent "#{shelf["width"] - (coord["start_width"] + coord["width"])}x#{shelf["height"]}+#{coord["start_width"] + coord["width"]}+#{shelf["start_height"]}"
    #   c.background "none"
    #   c.colorspace "sRGB"
    #   c.alpha "on"
    # end
    # #shelf_right_part = atlas_img.extent("#{shelf["width"] - (coord["start_width"] + coord["width"])}x#{shelf["height"]}+#{coord["start_width"] + coord["width"]}+#{shelf["start_height"]}")
    # shelf_right_part_h = shelf_right_part.height
    # shelf_right_part_w = shelf_right_part.width

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
  rescue => err
    render json: { error: "Error in delete_skyline in sprite_controller: " + err.message }
  end

end
