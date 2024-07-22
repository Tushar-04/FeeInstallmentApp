Rails.application.routes.draw do
  # Route for new user form
  get 'users/new', to: 'users#new', as: 'new_user'
  
  # Route to handle user creation
  post 'users', to: 'users#create'

  # Route for showing user details and installments
  get 'users/:id', to: 'users#show', as: 'user'
  
  # Route to handle installment payments and adjustments
  patch 'users/:user_id/fee_installments', to: 'fee_installments#update', as: 'user_fee_installments'

  root 'users#new'
end
