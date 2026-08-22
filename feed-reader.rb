require 'rss'
require 'open-uri'

module Jekyll
  class FeedGenerator < Generator
    def generate(site)
      feed_url = site.config['feed_url']
      rss = RSS::Parser.parse(URI.open(feed_url).read, false)
      site.data['feed'] = rss
    end
  end
end
