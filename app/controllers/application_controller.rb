class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_request

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = jwt_decode(token)
    if decoded
      @current_user = User.find(decoded[:user_id])
      if @current_user.avatar.attached?
        render json: { user_id: @current_user.id, username: @current_user.username, avatar_url: url_for(@current_user.avatar) }
      else
        render json: { user_id: @current_user.id, username: @current_user.username }
      end
    end
  rescue
    render json: { error: 'Not Authorized' }
  end

  private

  SECRET_KEY = Rails.application.credentials.secret_key_base

  def jwt_encode(payload)
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue
    nil
  end
end
