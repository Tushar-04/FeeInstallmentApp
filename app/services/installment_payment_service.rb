class InstallmentPaymentService
  def initialize(user_id, installment_id, payment_amount, adjustment_type)
    @user = User.find(user_id)
    @installment = FeeInstallment.find_by(user_id: @user.id, id: installment_id)
    @payment_amount = payment_amount.to_i
    @adjustment_type = adjustment_type
  end

  def process_payment
    raise NotFoundError, "Invalid installment" unless @installment.present? 

    validate_payment

    case @adjustment_type
    when 'adjust_extra'
      adjust_extra_installment
    when 'adjust_remaining'
      add_to_next_installment
    when 'new'
      create_new_installment
    when 'none'
      pay_installment
    else
      raise ArgumentError, "Invalid adjustment type: #{@adjustment_type}"
    end
  end

  private

  def validate_payment
    case @adjustment_type
    when 'adjust_extra'
      raise ArgumentError, "Payment amount must be greater than the installment amount for 'adjust_extra'" unless @installment.amount.to_i < @payment_amount
    when 'adjust_remaining', 'new'
      raise ArgumentError, "Payment amount must be less than the installment amount for '#{@adjustment_type}' and positive" unless @installment.amount.to_i > @payment_amount && @payment_amount.positive?
    when 'none'
      raise ArgumentError, "Payment amount must equal the installment amount for 'none'" unless @installment.amount.to_i == @payment_amount
    else
      raise ArgumentError, "Invalid adjustment type: #{@adjustment_type}"
    end
  end

  def pay_installment
    @installment.update(status: :paid)
  end

  def adjust_extra_installment
    raise ArgumentError, "Payment amount cannot be greater than remaining fees" if @payment_amount > remaining_fees

    extra_amount = @payment_amount - @installment.amount
    @installment.update(amount: @payment_amount, status: :paid)

    updated_installments = []
    @user.fee_installments.where(status: :unpaid).each do |fee_installment|
      if extra_amount >= fee_installment.amount
        extra_amount -= fee_installment.amount
        fee_installment.update(amount: 0, status: :paid)
        updated_installments << fee_installment
      else
        fee_installment.update(amount: fee_installment.amount - extra_amount)
        updated_installments << fee_installment
        break
      end
    end

    FeeInstallment.import updated_installments, on_duplicate_key_update: [:amount, :status]
  end

  def add_to_next_installment
    next_installment = @user.fee_installments.unpaid.second
    return create_new_installment unless next_installment

    next_amount = next_installment.amount + (@installment.amount - @payment_amount)
    next_installment.update(amount: next_amount)
    @installment.update(amount: @payment_amount, status: :paid)
  end

  def create_new_installment
    new_amount = @installment.amount - @payment_amount
    @installment.update(amount: @payment_amount, status: :paid)

    FeeInstallment.create!(
      user_id: @user.id,
      amount: new_amount,
      status: :unpaid
    )
  end

  def remaining_fees
    @user.fee_installments.where(status: :unpaid).sum(:amount).to_i
  end
end