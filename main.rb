     
require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development? 
require 'bcrypt'
require_relative 'db/helpers.rb'
require 'httparty'
require 'date'
require 'time'
require 'cloudinary'
require 'pg'

enable :sessions

get '/' do
  
  if logged_in?
    sql = 'SELECT DISTINCT
    hums.id,
    hums.user_id AS author_id,
    hums.text,
    (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS age,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like,
    users.display_name,
    users.username,
    users.photo_url
    FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id
    INNER JOIN users ON users.id = hums.user_id
    WHERE follows.user_id = $2
    ORDER BY age ASC;'
    hums = run_sql(sql,[current_user()['id'], current_user()['id']])
    erb :index, locals: {
      hums: hums
    }
  else
    erb :index
  end

end


get '/signup' do
  erb :signup
end


post '/create_user' do
  if already_user?(params[:email])
    erb :already_user
  else
    create_user(params[:email],params[:password],params[:username])
    redirect '/'
  end
end

post '/session' do
  if valid_user?(params[:email],params[:password])
    users = run_sql('SELECT * FROM users WHERE email = $1;', [params[:email]])
    logged_in_user = users[0]
    session[:user_id] = logged_in_user["id"]
    if logged_in_user["display_name"] == nil
      erb :complete_profile, locals: {
        profile: logged_in_user
      }
    else
      redirect '/'
    end
  else
    erb :login_fail
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/'
end

post '/hums' do
  redirect '/' unless logged_in?
  sql = 'INSERT INTO hums (text, created_at, user_id) VALUES ($1,$2,$3);'
  run_sql(sql,[params[:text], Time.new, current_user()['id']])
  redirect '/'
end

get '/:username' do
  redirect '/' unless logged_in?

  if params[:username] == 'hummers'
    sql = 'select * from users'
    hummers = run_sql(sql)
    erb :hummers, locals: {
    hummers: hummers
    }
  else
    sql = 'SELECT * FROM users WHERE username = $1;'
    results = run_sql(sql, [params[:username]])
    follow_sql = 'SELECT * FROM follows WHERE user_id = $1 AND followed_id = $2;'
    follow_results = run_sql(follow_sql, [current_user()['id'], results[0]['id']])
    follows_count_sql = 'SELECT COUNT(*) FROM follows WHERE user_id = $1'
    follows_count = run_sql(follows_count_sql, [current_user()['id']])
    follower_count_sql = 'SELECT COUNT(*) FROM follows WHERE followed_id = $1'
    follower_count = run_sql(follower_count_sql, [current_user()['id']])
    hum_sql = 'SELECT DISTINCT hums.id, hums.user_id AS author_id, text, hums.created_at, (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS age, (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like, users.display_name, users.username, users.photo_url FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id INNER JOIN users ON users.id = hums.user_id WHERE hums.user_id = $2 ORDER BY created_at DESC;'
    hum_results = run_sql(hum_sql, [current_user()['id'], results[0]['id']])
    erb :profile, locals: {
      profile: results[0],
      follow_results: follow_results,
      hums: hum_results,
      follows_count: follows_count[0],
      follower_count: follower_count[0]
    }
  end
end

post '/settings/profile' do
  redirect '/' unless current_user()['id'] == params['id']
  sql = 'SELECT * FROM users WHERE id = $1'
  profile = run_sql(sql, [params['id']])
  erb :edit_profile, locals: {
    profile: profile[0]
  }

end

options = {
  cloud_name: ENV["CLOUDINARY_CLOUD_NAME"],
  api_key: ENV["CLOUDINARY_API_KEY"],
  api_secret: ENV["CLOUDINARY_API_SECRET"]
}

put '/settings/profile/:id' do
    redirect '/' unless logged_in?
    # Cloudinary::Uploader.upload(file, options)
    if params['photo_url'] == nil
      sql = 'UPDATE users SET display_name = $1, date_of_birth = $2, tagline = $3 WHERE id = $4;'
      run_sql(sql, [params['display_name'], params['date_of_birth'], params['tagline'], params[:id]])
      redirect '/'
    else
      response = Cloudinary::Uploader.upload(params['photo_url']['tempfile'],options)
      sql = 'UPDATE users SET display_name = $1, photo_url = $2, date_of_birth = $3, tagline = $4 WHERE id = $5;'
      run_sql(sql, [params['display_name'], response['url'], params['date_of_birth'], params['tagline'], current_user()['id']])
      redirect '/'
    end
end

post '/follows' do
  redirect '/' unless logged_in?
  sql = 'INSERT INTO follows (user_id, followed_id) VALUES ($1, $2);'
  run_sql(sql,[current_user()['id'],params[:id]])
  redirect "/#{params[:username]}"
end

delete '/follows' do
  redirect '/' unless logged_in?
  sql = 'DELETE FROM follows WHERE user_id = $1 AND followed_id = $2;'
  run_sql(sql,[current_user()['id'],params[:id]])
  redirect "/#{params[:username]}"
end

post '/likes' do
  redirect '/' unless logged_in?
  sql = 'INSERT INTO likes (user_id, hum_id) VALUES ($1, $2);'
  run_sql(sql,[current_user()['id'],params[:id]])
  redirect '/'
end

delete '/likes' do
  redirect '/' unless logged_in?
  sql = 'DELETE FROM likes WHERE user_id = $1 AND hum_id = $2;'
  run_sql(sql,[current_user()['id'],params[:id]])
  redirect '/'
end

get '/hummers' do
  sql = 'select * from users'
  hummers = run_sql(sql)
  erb :hummers, locals: {
    hummers: hummers
  }
end