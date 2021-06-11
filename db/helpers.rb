require 'pg'
require 'bcrypt'
require 'date'
require 'time'

def run_sql(sql,params = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'hummer'})
    response = db.exec_params(sql,params)
    db.close
    return response
end

def current_user
    run_sql('select * from users where id = $1;', [session[:user_id]])[0]
end
  
def logged_in?
    if session[:user_id] != nil
        return true
    else
        return false
    end
end

def create_user(email, password, username)
    password_digest = BCrypt::Password.create(password)
    sql = "INSERT INTO users (email, password_digest, username, created_at) VALUES ('#{email}','#{password_digest}','#{username}','#{Time.new}');"
    run_sql(sql)
    sql_id = 'SELECT * FROM users WHERE email = $1'
    results = run_sql(sql_id,[email])
    sql_follow = "INSERT INTO follows (user_id, followed_id) VALUES ($1, $2);"
    run_sql(sql_follow,[results[0]['id'], results[0]['id']])
end

def valid_user?(email,password)
    users = run_sql('SELECT * FROM users WHERE email = $1;', [params[:email]])
    if users.count > 0 && BCrypt::Password.new(users[0]['password_digest']) == params['password']
        return true
    else
        return false
    end
end

def already_user? (email)
    users = run_sql('SELECT * FROM users WHERE email = $1', [email])
    if users.count > 0
     return true
    else
      return false
    end
end

def age_in_units(hum_age) 
    if hum_age < 60
        return "#{hum_age}s" 
    elsif hum_age/60 < 60
        return "#{hum_age / 60}m" 
    elsif hum_age/60/60 < 24
        return "#{hum_age / 60 / 60}h" 
    elsif hum_age/60/60/24 < 7
        return "#{hum_age / 60 / 60 / 24}d" 
    elsif hum_age/60/60/24/7 < 4
        return "#{hum_age / 60 / 60 / 24 / 7}w" 
    elsif hum_age/60/60/24/7/4 < 12
        return "#{hum_age / 60 / 60 / 24 / 7 / 4}m" 
    else
        return "#{hum_age / 60 / 60 / 24 / 7 / 4 / 12}y" 
    end
end