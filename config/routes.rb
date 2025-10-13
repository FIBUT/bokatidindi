Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'welcome#index'

  get 'pages/um_bokatidindi'
  get 'pages/privacy_policy'
  get 'pages/open_data'

  get 'baekur/', to: 'books#index'
  get 'baekur/sida/:page', to: 'books#index'

  get 'baekur/flokkur/:category', to: 'books#index', as: 'category'
  get 'baekur/flokkur/:category/sida/:page', to: 'books#index'

  get 'baekur/utgefandi/:publisher', to: 'books#index', as: 'publisher'
  get 'baekur/utgefandi/:publisher/sida/:page', to: 'books#index'

  get 'baekur/hofundur/:author', to: 'books#index', as: 'author'
  get 'baekur/hofundur/:author/sida/:page', to: 'books#index'

  get 'baekur/leit/:search', to: 'books#index'

  get 'bok/:slug', to: 'books#show', as: 'book'

  get 'xml_feeds/editions_for_print/:id', to: 'xml_feeds#edition_for_print'
  get 'xml_feeds/editions_for_print/current', to: 'xml_feeds#edition_for_print'

  get 'argangar', to: 'editions#index'
  get 'argangar/:id', to: 'editions#show'

  get 'print_locations', to: 'print_locations#index'

  get 'manifest.json', to: 'welcome#manifest'
end
