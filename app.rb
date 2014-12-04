require "sinatra"
require "pony"
require "data_mapper"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/rating.db")

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end

class Rating
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :email, String
	property :design, Integer
	property :content, Integer
	property :speed, Integer
	property :overall, Integer

end

Rating.auto_upgrade!

get "/" do
	erb :index, layout: :default
end

get "/rating_list" do
	protected!
	@ratings = Rating.all
	erb :rating_list, layout: :default
end

post "/rating" do 
	
	Pony.mail(to: params[:email],
		from: "valid email", 
		reply_to: "valid email",
		subject: "#{params[:name]}, thanks for your rating!",
		body: "Thank you for rating my site!",
		via: :smtp,
		via_options: {
			address: "smtp.gmail.com",
			port: "587",
			user_name: "answerawesome",
			password: "PASSWORD",
			authentication: :plain,
			enable_starttls_auto: true
			})

	Rating.create(
		name: params[:name],
		email: params[:email],
		design: params[:design],
		content: params[:content],
		speed: params[:speed],
		overall: params[:overall]
		)

	erb :thank_you, layout: :default
end