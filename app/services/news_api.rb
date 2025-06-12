# frozen_string_literal: true

# app/services/news_api.rb
class NewsApi
  require 'net/http'
  require 'json'

  API_KEY = '413208839e074faab821131968561bfb'

  def self.get_top_articles(query, limit)
    encoded_query = URI.encode_www_form_component(query)
    url = URI("https://newsapi.org/v2/everything?q=#{encoded_query}&pageSize=#{limit}&apiKey=#{API_KEY}")
    response = Net::HTTP.get(url)
    json_response = JSON.parse(response)
    json_response['articles']
  end
end
