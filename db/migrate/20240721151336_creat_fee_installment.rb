class CreatFeeInstallment < ActiveRecord::Migration[7.1]
  def change
    create_table :fee_installments do|t|
      t.integer :amount, null: false
      t.references :user, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
