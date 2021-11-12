Rails.application.routes.draw do
  root 'welcome#index'

  get 'pages/um_bokatidindi'
  get 'pages/privacy_policy'

  resources :books, path: 'baekur', only: [:index]
  resources :books, path: 'bok', param: :slug, only: [:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
