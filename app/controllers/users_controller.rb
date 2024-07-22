class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      total_amount = params[:total_amount].to_i
      number_of_installments = params[:number_of_installments].to_i
      @user.create_installments(total_amount, number_of_installments)
      redirect_to @user, notice: 'User and installments created successfully.'
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    @installments = @user.fee_installments.order(:id)
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
