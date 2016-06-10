require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './model'

get '/'
  @post = Post.order(updated_at: :desc)
  
  erb :imdex
end

get '/posts' do
  Post.create(title: params[:title], content: params[:body])
end

post '/posts/:id/comment' do
  post = Post.find(params[:id])
  post.comments.create(body: params[:comment])
  
  redirect '/'
end