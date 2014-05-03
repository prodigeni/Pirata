require 'nokogiri'
require 'open-uri'
require 'collection'
require 'torrent'
require 'user'

module Pirata
  class API
    
    attr_reader :base_url
    
    def initialize(base_url)
      @base_url = base_url
    end
    
    # Return the n most recent torrents from a category
    # Searches all categories if none supplied
    def top(category = "all", n = "100")
      html = Nokogiri::HTML(open(@base_url + '/top/' + URI.escape(category)))
      
      p collect_results(html)
    end
    
    private #---------------------------------------------
    
    # From a results table, collect and build all Torrents
    # into a Collection object
    def collect_results(html)
      results = Collection.new
           
      html.css('#searchResult tr').each do |row|
        category = row.search('td a')[0]
        next if category.nil?
        
        h = {}
        h[:category]    = category.text
        h[:title]       = row.search('.detLink')[0].text
        h[:url]         = @base_url + row.search('.detLink').attribute('href').to_s
        h[:id]          = h[:url].split('/')[2]
        h[:magnet_link] = row.search('td a')[3]['href']
        h[:seeders]     = row.search('td')[2].text.to_i
        h[:leechers]    = row.search('td')[3].text.to_i
        h[:uploader]    = Pirata::User.new(row.search('td a')[5].text, @base_url)
        results.add(Pirata::Torrent.new(h))
      end
      results
    end
    
  end
end

Pirata::API.new('http://thepiratebay.se').top