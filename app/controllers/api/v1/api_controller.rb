class Api::V1::ApiController < ActionController::API
  if Rails.env == "production"
    SECRET_KEY = Rails.application.secret_key_base
  else
    SECRET_KEY = Rails.application.secrets.secret_key_base
  end

  def authorize_request
    header = request.headers['Authorization']
    return  render json: { errors: "Invalid authorization Token" }, status: :unauthorized if header.nil?

    header = header.split(' ').last if header
    begin
      decoded = decode(header)
      @current_user = User.find_by_id(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end

