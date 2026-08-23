
require 'json'
require 'fileutils'

feed = JSON.parse(File.read("feed.json"))
entries = feed["feed"]["entry"]

FileUtils.mkdir_p("posts")

generated = []
discarded_no_alternate = []
auto_slugged = []
collisions = []

entries.each do |entry|
  title = entry["title"]["$t"]
  links = entry["link"]

  alt = links.find { |l| l["rel"] == "alternate" }

  if alt.nil?
    discarded_no_alternate << title
    puts "Sin link alternativo: #{title}"
    next
  end

  slug = alt["href"].split("/").last
  slug = slug.gsub(/\.html$/, "") if slug

  if slug.nil? || slug.strip.empty?
    auto = title.downcase
                .gsub(/[^a-z0-9\s]/, '')
                .gsub(/\s+/, '-')
                .strip

    if auto.empty?
      auto = "post-#{entry['id']['$t'].split(':').last}"
    end

    slug = auto
    auto_slugged << title
    puts "Slug generado automáticamente: #{title} → #{slug}"
  end

  filename = "posts/#{slug}.html"

  if File.exist?(filename)
    collisions << title
    puts "Colisión de slug (ya existe #{filename}): #{title}"
    next
  end

  content = entry["content"]["$t"]
  File.write(filename, content)

  generated << title
  puts "Generado correctamente: #{title} → #{filename}"
end

puts "\n=== RESUMEN ==="
puts "Generados: #{generated.count}"
puts "Slugs automáticos: #{auto_slugged.count}"
puts "Sin link alternativo: #{discarded_no_alternate.count}"
puts "Colisiones: #{collisions.count}"
