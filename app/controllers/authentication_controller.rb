class AuthenticationController < ApplicationController
  before_action :authenticate_request, only: [:change_password, :change_username, :change_avatar, :destroy]

  def register
    reg_params = params.permit(:username, :password, :avatar)
    reg_params[:username] = Rails::Html::SafeListSanitizer.new.sanitize(reg_params[:username], tags: [])
    user = User.new(reg_params.permit(:username, :password))

    user.validate
    error_username = "Username " + user.errors[:username][0] unless user.errors[:username][0].nil?
    error_password = "Password " + user.errors[:password][0] unless user.errors[:password][0].nil?

    if reg_params[:avatar]
      if !%w[image/jpeg image/png image/jpg].include?(reg_params[:avatar].content_type)
        render json: { error_avatar: "Avatar file must be one of type: png, jpg, jpeg",
                       error_username: error_username,
                       error_password: error_password }
        return
      elsif reg_params[:avatar].size > 1.megabyte
        render json: { error_avatar: "Avatar file size must be less then 1Mb",
                       error_username: error_username,
                       error_password: error_password }
        return
      end
    end
    if user.save
        user.avatar.attach(reg_params[:avatar])
        render json: { message: 'Account successfully registered' }
    else
      render json: { error_username: error_username, error_password: error_password }
    end
  rescue => err
      render json: { error: err }
  end

  def login
    login_params = params.permit(:username, :password)

    username = Rails::Html::SafeListSanitizer.new.sanitize(login_params[:username], tags: [])

    user = User.find_by(username: username)
    if user && user.authenticate(login_params[:password])
      token = jwt_encode(user_id: user.id)
      if user.avatar.attached?
        render json: {token: token, user_id: user.id, username: user.username, avatar_url: url_for(user.avatar) }
      else
        render json: { token: token, user_id: user.id, username: user.username }
      end
    else
      raise 'Invalid username or password'
    end
  rescue => err
    render json: { error: err }
  end

  def change_username
    raise "Can't find current user" unless @current_user

    new_username = params.permit(:username)
    new_username = Rails::Html::SafeListSanitizer.new.sanitize(new_username[:username], tags: [])

    if @current_user.update(username: new_username) && @current_user.save
      render json: { username: @current_user.username }
    else
      render json: { error_username: "Username " + @current_user.errors[:username][0] }
    end

  rescue => err
    render json: { error: err }
  end

  def change_password
    raise "Not authenticated" unless @current_user

    passwords_params = params.permit(:new_password, :old_password)
    new_password = Rails::Html::SafeListSanitizer.new.sanitize(passwords_params[:new_password])
    old_password = Rails::Html::SafeListSanitizer.new.sanitize(passwords_params[:old_password])

    if new_password == old_password
      render json: { error_password: "Password are similar" }
      return
    end

    unless @current_user.authenticate(old_password)
      render json: { error_password: "Wrong old password" }
      return
    end

    if @current_user && @current_user.update(password: new_password)
      render json: { message: "Password updated successfully" }
    else
      render json: { error_password: "New password " +  @current_user.errors[:password][0] }
    end
  rescue => err
    render json: { error: err }
  end

  def change_avatar
    raise "Not authenticated" unless @current_user

    avatar = params.permit(:avatar)[:avatar]
    raise "No avatar provided" unless avatar


    if !%w[image/jpeg image/png image/jpg].include?(avatar.content_type)
      render json: { error_avatar: "Avatar file must be one of type: png, jpg, jpeg"}
      return
    elsif avatar.size > 1.megabyte
      render json: { error_avatar: "Avatar file size must be less then 1Mb"}
      return
    end

    if @current_user.avatar.attach(avatar)
      render json: { avatar: url_for(@current_user.avatar) }
    else
      render json: { error_avatar: "Avatar" + @current_user.errors[:avatar][0] }
    end
  rescue => err
    render json: { error: err }
  end

  def destroy
    raise "Not authenticated" unless @current_user
    if @current_user && @current_user.destroy
      render json: { message: "User deleted successfully" }
    else
      render json: { error: @current_user.errors.full_messages }
    end
  end

  private

  def user_params
    params.permit(:username, :password)
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue
    nil
  end
end
