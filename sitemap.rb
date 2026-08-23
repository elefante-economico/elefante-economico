require 'builder'

# Ruta de salida
output = File.open("sitemap.xml", "w")

xml = Builder::XmlMarkup.new(target: output, indent: 2)
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  Dir.glob("posts/*.html").each do |file|
    xml.url do
      xml.loc("https://elefante-economico.github.io/#{file}")
      xml.lastmod(File.mtime(file).strftime("%Y-%m-%d"))
      xml.changefreq("monthly")
      xml.priority("0.8")
    end
  end
end

output.close
puts "✔ Sitemap generado correctamente."
