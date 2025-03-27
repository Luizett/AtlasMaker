class AuthenticationController < ApplicationController
  #skip_before_action :authenticate_request, only: [:register, :login]
  before_action :authenticate_request, only: [:change_password, :change_username, :destroy]

  def register
    user = User.new(params.permit(:username, :password))
    if user.save
      user.avatar.attach(params[:avatar]) if params[:avatar] # Прикрепляем аватар, если он есть
      render json: { message: 'Account registered' }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  def login
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      token = jwt_encode(user_id: user.id)
      if user.avatar.attached?
        render json: {token: token, user_id: user.id, username: user.username, avatar_url: url_for(user.avatar) }
      else
        render json: { token: token, user_id: user.id, username: user.username }
      end
    else
      render json: { error: 'Invalid username or password' }
    end
  end

  def change_username
    # TODO валидация приходящих данных
    if User.find_by(username: params[:username])
      render json: { errors: "Username already taken" }
    else
      user = User.find_by_id(params[:user_id])
      if user && user.update_attribute(:username, params[:username])
        render json: { username: user.username }
      else
        render json: { errors: "Something went wrong" }
      end
    end
  end

  def change_password
    user = User.find_by_id(params[:user_id])
    if user && user.update_attribute(:password, params[:password])
      render json: { username: user.username }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  def destroy
    # TODO
    # доп проверка что пользователь зарегестрирован и что удаляет только свой аккаунт

    user = User.find_by_id(params[:user_id]) # Находим пользователя по ID

    if user && user.destroy # Пытаемся удалить пользователя
      render json: { message: "User deleted successfully" }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  private

  def user_params
    params.permit(:username, :password)
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
