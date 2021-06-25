require 'pg'
require_relative 'helpers.rb'
require 'time'

# ids = [1,2,3,4,5,6,7]

# usernames = ['chrispollard','ernest','frida','fannieF','mary','adalove','motherT']

# display_names = ['Chris Pollard','Ernest Hemingway','Frida Kahlo','Fannie Farmer','Mary Anning','Ada Lovelace', 'Mother Theresa']

# date_of_births = ['1985-09-24','1899-07-21','1907-07-06','1857-03-23','1799-05-21','1815-12-10','1910-08-26']

# taglines = ['Founder of Hummer and father of one superstar #bitcoin','Novelist, short-story writer, jounalist and sportsman #IcebergTheory','Painter #MexicoForLife','Culinary expert, Massachusetts #BostonCookingSchool','Fossil collector, dealer and palaeontologist. Special interest in Jurassic marine fossils','Mathematician and writer, worked on the first general-purpose computer, based in Nottingham.','Saint Teresa of Calcutta, helping out a bunch of peeps.']

# photo_url = ['https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', 'https://schooloflanguages.sa.edu.au/wp-content/uploads/2017/11/placeholder-profile-sq.jpg', ]

# ids.each do |id| 
#     create_user("#{usernames[id-1]}@gmail.com", 'pudding', usernames[id-1])
# end

# ids.each do |id| 
#     sql = 'UPDATE users set display_name = $1, date_of_birth = $2, tagline = $3, photo_url = $4 WHERE id = $5' 
#     run_sql(sql,[display_names[id-1], date_of_births[id-1], taglines[id-1], photo_url[id-1], id])
# end

ids = [1,2,6,4,5,3,7]

quotes = ['The greatest glory in living lies not in never falling, but in rising every time we fall.', 'The way to get started is to quit talking and begin doing.','Geez my pants are tight today','If life were predictable it would cease to be life, and be without flavor.','f you look at what you have in life, youll always have more. If you look at what you dont have in life, youll never have enough.','I think, therefore, I am.','I think, therefore, I am.','The unexamined life is not worth living.','You can discover more about a person in an hour of play than in a year of conversation.','Where there is love there is life.']

20.times do

    ids.each do |id|
        sql = 'INSERT INTO hums (user_id, text, created_at) VALUES ($1,$2,$3);' 
        run_sql(sql,[id,quotes.sample,Time.new])
    end

end