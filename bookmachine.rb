set :haml, :format => :html5

get '/stylesheets/:stylesheet.css' do
  scss params[:stylesheet].to_sym
end

get '/all' do
  @posts = Post.all
  @posts_by_month = @posts.group_by(&:month)

  @title = "My book"
  haml :all, :layout => :print
end
