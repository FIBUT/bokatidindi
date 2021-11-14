Rails.application.routes.draw do
  root 'welcome#index'

  get 'pages/um_bokatidindi'
  get 'pages/privacy_policy'

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
end
