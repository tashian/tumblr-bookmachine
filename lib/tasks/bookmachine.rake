STDOUT.sync = true

TUMBLR_KEY = 'YOUR_API_KEY'
TUMBLR_BLOG = 'staff.tumblr.com'
TUMBLR_URL = "http://api.tumblr.com/v2/blog/#{TUMBLR_BLOG}"

task :default => "ingest:all"

task :environment do
  require 'rubygems'
  require 'sinatra'
  require 'nokogiri'
  require 'bookmachine'
  require 'httparty'
  require 'pp'
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
          post['created_at'] = {"$date" => post.delete('timestamp')}
          f.write(post.to_json + "\n")
        end
      end

    end

    puts "Now import data/posts.json into mongodb: mongoimport -d tumblr-bookmachine -c posts data/posts.json"
  end
end

namespace :publish do
  desc "Render all books as PDFs to app root."
  task :all => :environment do
    years = Year.all
    years.each do |y|
      year = y.year_string
      `prince http://localhost:9292/year/#{year} -o #{year}.pdf`
    end
  end

  desc "Render a specific year"
  task :year => :environment do
    if ENV["YEAR"]
      if Year.find_by_year_string(ENV["YEAR"])
        `prince http://localhost:9292/year/#{ENV['YEAR']} -o #{ENV['YEAR']}.pdf`
      else
        puts "That year could not be found."
      end
    else
      puts "Please specify a year eg YEAR=1999"
    end
  end
end
