class FeeInstallment < ApplicationRecord
  belongs_to :user

  enum status: {
    unpaid: 0,
    paid: 1
  }
end