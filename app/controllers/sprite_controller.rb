class SpriteController < ApplicationController
  # def show
  #   # todo return image information
  #   sprite = User.find_by_id(params[:user_id]).atlas.find_by_id(params[:atlas_id]).sprites.find_by_id(params[:sprite_id])
  # end

  def show_all
    sprites = []
    User.find_by_id(params[:user_id]).atlas.find_by_id(params[:atlas_id]).sprites.each do |sprite|
      sprites.push({
        id: sprite.id,
        filename: sprite.filename.to_s,
        path: url_for(sprite)
      })
    end
    render json: { sprites: sprites }
  end

  def create
    sprite = User.find_by_id(params[:user_id]).atlas.find_by_id(params[:atlas_id]).sprites.create
    if sprite
      if sprite.sprite_img.attach(params[:img])
        sprite.save
        render json: {img: params[:img], filename: "temptitle.png"}
      else
        render json: {errors: "error while attaching sprite image"}
      end
    else
      render json: {errors: "error while create sprite" }
    end
  end

  def delete
    sprite = User.find_by_id(params[:user_id]).atlas.find_by_id(params[:atlas_id]).sprites.find_by_id(params[:sprite_id])
    if sprite.destroy
      render json: {message: 'sprite successfully deleted'}
    else
      render json: {errors: "error while deleting sprite image"}
    end
  end
end
