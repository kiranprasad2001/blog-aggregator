require 'yaml'
require 'rss'
require 'open-uri'
require 'json'
require 'nokogiri'

def fetch_rss_feeds
    blog_sources = YAML.load_file('_data/blog_sources.yml')['blogs']
    aggregated_posts = []

    blog_sources.each do |blog|
        begin
            URI.open(blog['rss']) do |rss|
                feed = RSS::Parser.parse(rss)

                feed.items.each do |item|
                    # Title extraction
                    title = if feed.feed_type == 'atom'
                                item.title.content
                            elsif item.title.respond_to?(:text)
                                Nokogiri::HTML(item.title).text
                            else
                                item.title.to_s
                            end

                    # Link extraction
                    link =  if item.link.respond_to?(:href)
                                item.link.href
                            else
                                item.link.to_s
                            end

                    # pubDate and excerpt extraction
                    if feed.feed_type == 'atom'
                        pub_date = item.updated.to_s
                        excerpt = item.summary || item.content
                    else
                        pub_date = item.pubDate.to_s
                        excerpt = item.description || item.content
                    end

                    # Author extraction
                    author =if item.author&.name
                                item.author.name
                            elsif item.dc_creator
                                item.dc_creator
                            else
                                Nokogiri::HTML(feed.title).text
                            end

                    # Tags/Categories extraction
                    tags =  if feed.feed_type == 'atom'
                                item.categories&.map(&:term) || ['Uncategorized']
                            else
                                item.categories&.map(&:content) || ['Uncategorized']
                            end

                    aggregated_posts << {
                        'title' => title,
                        'link' => link,
                        'pubDate' => Date.parse(pub_date).to_s,
                        'excerpt' => excerpt,
                        'author' => author,
                        'tags' => tags
                    }
                end
            end
        rescue OpenURI::HTTPError => e
            puts "Error opening feed URL: #{blog['rss']} - #{e.message}"
        end
    end

    aggregated_posts
end

aggregated_posts = fetch_rss_feeds

File.open('_data/posts.json', 'w') do |f|
    f.write(JSON.pretty_generate(aggregated_posts))
end

fetch_rss_feeds