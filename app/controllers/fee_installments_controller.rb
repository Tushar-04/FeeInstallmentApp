class FeeInstallmentsController < ApplicationController
  def update
    @user = User.find(params[:user_id])

    service = InstallmentPaymentService.new(
      @user.id, params[:installment_id], params[:payment], params[:adjustment]
    )

    begin
      service.process_payment
      flash[:notice] = 'Payment processed successfully.'
    rescue StandardError => e
      flash[:alert] = "Error: #{e.message}"
    end

    redirect_to user_path(@user)
  end
end