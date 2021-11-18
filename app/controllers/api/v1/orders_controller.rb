class Api::OrdersController < Api::ApiController
  before_action :authorize_request
  before_action :set_user
  load_and_authorize_resource param_method: :order_params

  # GET  /api/orders
  def index
    orders = current_user.is_admin ? Order.all : current_user.orders
    render json: orders
  end

  # POST  /api/orders
  def create
    address = @user.addresses.create(address_params)
    order = @user.orders.new(order_params)
    order.address_id = address.id
    
    if order.save
      order.order_items.create(order_items_params)
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages },
        status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by_id params[:user_id]
  end

  def order_params
    params.permit(:name, :address_id, :user_id)
  end

  def address_params
    params[:addresses].permit!
  end

  def order_items_params
    params[:order_item].permit!
  end
end