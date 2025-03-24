class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JwtDecode(token)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

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
