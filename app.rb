require 'rubygems'
require 'sinatra'
require 'chronic'
require 'maneki'
require 'moredown'
require 'erb'
require 'haml'

require 'models'
require 'helpers'


get '/' do
  @posts = Post.index || raise(Sinatra::NotFound)
  haml :index
end


get '/tags/:tag/?' do
  @tag = params[:tag]
  @posts = Post.find_tagged_with(@tag)
  haml :tag
end


get '/archive/?' do
  @posts_by_month_and_year = Post.archive
  haml :archive
end


get '/rss' do
  @posts = Post.index
  content_type 'application/rss+xml'
  erb :rss, layout: false
end


get '/sitemap.xml' do
  @posts = Post.all
  content_type 'text/xml'
  erb :sitemap, :layout => false
end


get '/media/:file.:ext' do
  filename = File.dirname(__FILE__) + '/posts/media/' + params[:file] + '.' + params[:ext]
  if File.file? filename
    send_file(filename)
  else
    raise(Sinatra::NotFound)
  end
end


get '/:slug.text' do
  filename = File.dirname(__FILE__) + '/posts/' + params[:slug] + '.text'
  if File.file? filename
    content_type 'text/plain'
    File.open filename
  end
end


get '/:slug/?' do
  @post = Post.find(params[:slug])
  
  if @post
    haml :post
  else
    @keyword = params[:slug].gsub('-', ' ')
    @posts = Post.search(@keyword)
    haml :search
  end
end


not_found do
  haml :not_found
end