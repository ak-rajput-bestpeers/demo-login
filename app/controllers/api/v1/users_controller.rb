class Api::V1::UsersController < Api::V1::ApiController
  before_action :authorize_request, except: [:login, :create]

  #POST  /api/sign_up
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages },
        status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by_email(params[:email])
    if @user && @user.valid_password?(params[:password])
      token = JWT.encode({user_id: @user.id}, Rails.application.secrets.secret_key_base)
      render json: { token: token, email: @user.email }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end


  def reset_password
    if @current_user.valid_password?(reset_password_params[:old_password]).present?
      @current_user.update(password:reset_password_params[:new_password])
      render json: { success:true,message: "Password Change Successfully, Please login again to continue" }
    else
      render json: { success:false,message: "Old Password Is Wrong" }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def reset_password_params
    params.require(:user).permit(:email, :old_password, :new_password)
  end

  def login_params
    params.permit(:email, :password)
  end
end
