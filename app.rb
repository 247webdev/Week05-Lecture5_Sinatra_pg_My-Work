require 'sinatra'
require 'better_errors'
require 'pry' # allows binding.pry  to give you breakpoints in code
require 'pg'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'sinatrasql') # set is Sinatra based

before do
  @conn = settings.conn  # settings is Sinatra based
end

# root route
get '/' do
 p "hello world, I'm here"
  redirect '/authors'
end

# GET / - show all users
get '/authors' do
  authors = []
  @conn.exec("SELECT * FROM authors") do |result|
      result.each do |author|
        authors << author
        # authors.
        # authors.
      end
  end
  @authors = authors # this instance variable is needed so it can pass to the erb file. erb only takes instance variables
  erb :index
end

# NEW - display a form for making a new user
get '/authors/new' do
  erb :new
end

# SHOW a user's info by their id, this should display the info in a form
get '/authors/:id' do
  id = params[:id].to_i
  author = @conn.exec("SELECT * FROM authors WHERE id=$1",[id])
  @author = author[0]
  erb :show
end

# EDIT
get '/authors/:id/edit' do
  id = params[:id].to_i
  author = @conn.exec("SELECT * FROM authors WHERE id=$1", [id]) # params[:name] is whatever was typed into the form which then gets assigned into $1. this is sanitizing the input so SQL injection doesn't work
  @author = author[0] # the database returns an array so we're specifying the zero index (should be the only index anyway but we still have to specify it)
  erb :edit
end

# POST CREATE a user based on params from form
post '/authors' do
  @conn.exec("INSERT INTO authors (name) VALUES ($1)", [params[:name]]) # params[:name] is whatever was typed into the form which then gets assigned into $1. this is sanitizing the input so SQL injection doesn't work
  redirect to '/authors'
end

# PUT  update a author's info based on the form from GET /authors/:id
put '/authors/:id' do
  id = params[:id].to_i
  @conn.exec("UPDATE authors SET name=$2 WHERE id=$1", [id, params[:name]]) # params[:name] is whatever was typed into the form which then gets assigned into $1. this is sanitizing the input so SQL injection doesn't work
  redirect to '/authors'
end


# DELETE  delete a user by their id
delete '/authors/:id' do
  id = params[:id].to_i
  @conn.exec("DELETE FROM authors WHERE id=$1", [id]) # params[:name] is whatever was typed into the form which then gets assigned into $1. this is sanitizing the input so SQL injection doesn't work
  redirect to '/authors'
end