#!/usr/bin/env ruby
require 'json'
require 'fileutils'

feed = JSON.parse(File.read("feed.json"))
entries = feed["feed"]["entry"]

FileUtils.mkdir_p("posts")

def slugify(title)
  title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-')
end

entries.each do |entry|
  title = entry["title"]["$t"]
  content = entry["content"]["$t"]
  slug = slugify(title)
  path = "posts/#{slug}.html"

  File.write(path, <<~HTML)
  <html>
  <head>
    <meta charset="utf-8">
    <title>#{title}</title>
  </head>
  <body>
    #{content}
  </body>
  </html>
  HTML

  puts "Generado: #{slug}"
end

puts "\nTodos los posts fueron generados sin condiciones."

