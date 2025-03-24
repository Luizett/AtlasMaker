class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  # TODO
  # сверстать страницу регистрации и входа
  # проверить что оно работает и настроить глобальный стейт с токеном и с айди юзера
  # настроить роутинг
  # выводить при нажатии на иконку юзера или страницу входа или страницу юзера с  информацией о нём


  def register
    user = User.new(params.permit(:username, :password))
    if user.save
      user.avatar.attach(params[:avatar]) if params[:avatar] # Прикрепляем аватар, если он есть
      token = jwt_encode(user_id: user.id)
      render json: { token: token, user: user.id, avatar_url: url_for(user.avatar) }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  def login
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      token = jwt_encode(user_id: user.id)
      render json: { token: token, user_id: user.id, username: user.username }
    else
      render json: { error: 'Invalid username or password' }
    end
  end

  def change_username
    user = User.find_by(user_id: params[:user_id])
    if user.update(username: params[:username])
      render json: { username: user.username }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  def change_password
    user = User.find_by(username: params[:username])
    if user.update(username: params[:username_new])
      render json: { username: user.username }
    else
      render json: { errors: user.errors.full_messages }
    end
  end

  def destroy
    # TODO
    # доп проверка что пользователь зарегестрирован и что удаляет только свой аккаунт

    user = User.find(params[:id]) # Находим пользователя по ID

    if user.destroy # Пытаемся удалить пользователя
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
