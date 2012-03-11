STDOUT.sync = true

TUMBLR_KEY = 'MyPjY4V9IQCf7JEdtjob1lfxOHM7wg3LSs0AfBbLdvYBHBZR42'
TUMBLR_BLOG = 'learningrevolution.tumblr.com'
TUMBLR_URL = "http://api.tumblr.com/v2/blog/#{TUMBLR_BLOG}"

task :default => "fetch:tumblr"

task :environment do
  require 'bundler'

  Bundler.require
end

namespace :fetch do

  desc "Fetch posts from tumblr"
  task :tumblr => :environment do

    # How many posts are there?
    response = HTTParty.get(TUMBLR_URL + '/info?api_key=' + TUMBLR_KEY)
    info = JSON.parse(response.body)['response']['blog']
    posts = info['posts']
    pages = (posts / 20) + 1
    puts "#{posts} posts, #{pages} pages of 20"

    all_posts = []

    # Fix timestamps for mongo
    File.open("data/posts.json", 'w') do |f|
      pages.times do |i|
        offset = i*20
        u = TUMBLR_URL + '/posts?offset=' + offset.to_s + '&limit=20&api_key=' + TUMBLR_KEY
        r = HTTParty.get(u)
        posts = JSON.parse(r.body)['response']['posts']
        posts.each do |post|
          post['created_at'] = {"$date" => post.delete('timestamp') * 1000} # s => ms since epoch
          f.write(post.to_json + "\n")
        end
        print '.'
      end
      print "\n"
    end

    puts "Importing JSON data to mongodb"
    `mongoimport -d tumblr-bookmachine -c posts data/posts.json`
  end
end

namespace :publish do
  desc "Render the book as PDF to app root."
  task :all => :environment do
      `prince http://localhost:9292/all -o all.pdf`
  end
end
