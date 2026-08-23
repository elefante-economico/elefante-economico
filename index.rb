#!/usr/bin/env ruby
require 'json'

begin
  feed = JSON.parse(File.read("feed.json"))
rescue => e
  puts "✖ ERROR: No se pudo leer feed.json — #{e.message}"
  exit(1)
end

entries = feed["feed"]["entry"]

if entries.nil? || entries.empty?
  puts "✖ ERROR: feed.json no contiene entradas válidas."
  exit(1)
end

posts = entries.map do |entry|
  begin
    title = entry["title"]["$t"]
    link  = entry["link"].find { |l| l["rel"] == "alternate" }&.dig("href")
    date  = entry["published"]["$t"]

    next if link.nil?

    {
      title: title,
      slug: link.split("/").last.gsub(".html", ""),
      date: date
    }
  rescue
    next
  end
end.compact

if posts.empty?
  puts "✖ ERROR: No se pudieron extraer posts con link alternativo."
  exit(1)
end

# Ordenar por fecha descendente
posts = posts.sort_by { |p| p[:date] }.reverse

html = []
html << "<html><body>"
html << "<h1>El Elefante Económico — Índice</h1>"
html << "<ul>"

posts.each do |p|
  html << "<li><a href=\"posts/#{p[:slug]}.html\">#{p[:title]}</a> — #{p[:date][0..9]}</li>"
end

html << "</ul>"
html << "</body></html>"

begin
  File.write("index.html", html.join("\n"))
  puts "✔ Índice generado correctamente con #{posts.count} posts."
rescue => e
  puts "✖ ERROR: No se pudo escribir index.html — #{e.message}"
  exit(1)
end
