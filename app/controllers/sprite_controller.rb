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
  rescue => err
    render json: { error: "Error in delete_bookshelf in sprite_controller: " + err.message }
  end

  def delete_skyline
  rescue => err
    render json: { error: "Error in delete_skyline in sprite_controller: " + err.message }
  end

end
