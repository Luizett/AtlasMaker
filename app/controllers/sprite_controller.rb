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
    atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id].to_s unless atlas
    sprite = atlas.sprites.create
    raise "Something went wrong while creating sprite" unless sprite

    sprite.sprite_img.attach(params[:img])
    raise "error while attaching sprite" unless sprite.sprite_img.attached?

    if sprite.save
      render json: {
        sprite_id: sprite.id,
        filename: sprite.sprite_img.filename,
        sprite_img: url_for(sprite.sprite_img)
      }
    else
      raise "error while saving sprite"
    end
  rescue => err
    render json: { error: "Error in create: " + err.message }
  end



  def delete
    raise "user not auth " unless @current_user
    atlas = @current_user.atlases.find_by_id(params[:atlas_id])
    raise "can't find atlas with id: " + params[:atlas_id].to_s unless atlas
    sprite = atlas.sprites.find_by_id(params[:sprite_id])
    raise "can't find sprite with id: " + params[:sprite_id].to_s unless sprite
    if sprite.destroy
      render json: {message: 'sprite successfully deleted'}
    else
      raise "Something went wrong while deleting sprite"
    end
  rescue => err
    render json: { error: "Error in delete: " + err.message }
  end
end
