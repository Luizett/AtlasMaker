class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def sessionn
    header = request.headers['Authorization']
    raise "not authorized in session" unless header

    token = header.split(' ').last
    decoded = jwt_decode(token)
    @current_user = User.find(decoded[:user_id])
    raise "Can't find user with id #{decoded[:id]}" unless @current_user

    avatar_url =  url_for(@current_user.avatar) if @current_user.avatar.attached?
    render json: {
      user_id: @current_user.id,
      username: @current_user.username,
      avatar_url: avatar_url
    }
  rescue => e
    render json: { error: e.message }
  end

  def authenticate_request
    raise "empty request" unless request
    raise "empty headers in request" unless request.headers
    raise "header doesn't have Auth" unless request.headers.key?('Authorization')
    p request.headers
    header = request.headers['Authorization']
    raise 'Not Authorized in auth_request' + request.headers.to_s unless header

    token = header.split(' ').last
    #raise "empty token" unless token
    decoded = jwt_decode(token)
    raise 'Not Authorized in auth_request ' + token.to_s + decoded.to_s unless decoded

    @current_user = User.find_by_id(decoded[:user_id])

    raise "cant  find user with id " + decoded[:user_id] unless @current_user

  rescue => e
    render json: { error: "error in auth_request " + e.message }
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

  private




end
