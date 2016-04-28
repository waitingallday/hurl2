unless $LOAD_PATH.include? "."
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
end

begin
  require './env'
rescue LoadError 
  nil	
end

require 'app/app'

map "/js" do
  run Rack::Directory.new("./public/js")
end

map "/css" do
  run Rack::Directory.new("./public/css")
end

map "/img" do
  run Rack::Directory.new("./public/img")
end

map "/favicon.ico" do
  run Rack::File.new("./public/favicon.ico")
end

map "/robots.txt" do
  run Rack::File.new("./public/robots.txt")
end

run Hurl::App.new
