class User < ApplicationRecord
  has_many :fee_installments

  def create_installments(total_amount, number_of_installments)
    installment_amount = total_amount / number_of_installments

    installments = []
    number_of_installments.times do
      installments << FeeInstallment.new(
        user_id: self.id,
        amount: installment_amount, 
        status: :unpaid
      )
    end

    FeeInstallment.import installments
  end
end