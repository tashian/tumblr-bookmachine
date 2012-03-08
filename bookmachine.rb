require 'bundler'
Bundler.require

#these two are the application broken out a bit.
require 'helpers'
require 'models'

set :haml, :format => :html5

get '/stylesheets/:stylesheet.css' do
  scss params[:stylesheet].to_sym
end

get '/all' do
  @posts = Post.all(:order => :created_at.asc)
  @posts_by_month = @posts.group_by(&:month_with_year)

  @title = "Rahmin &amp; Carl Enterprises"
  haml :all, :layout => :print
end
