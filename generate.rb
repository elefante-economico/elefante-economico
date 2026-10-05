# encoding: UTF-8
#!/usr/bin/env ruby
require 'json'
require 'fileutils'

feed = JSON.parse(File.read("feed.json", encoding: "UTF-8"))
entries = feed["feed"]["entry"]

FileUtils.mkdir_p("posts")

def slugify(title)
  title
    .downcase
    .tr(
      "áéíóúüñ",
      "aeiouun"
    )
    .gsub(/[^a-z0-9\s-]/, '')
    .gsub(/\s+/, '-')
end

entries.each do |entry|
  title = entry["title"]["$t"]
  content = entry["content"]["$t"]
  link = entry["link"].find { |l| l["rel"] == "alternate" }["href"]
slug = File.basename(link, ".html")
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

