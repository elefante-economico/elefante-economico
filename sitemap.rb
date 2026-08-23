require 'builder'

# ============================
# ARCHIVO DE SALIDA
# ============================

output = File.open("sitemap.xml", "w")

xml = Builder::XmlMarkup.new(target: output, indent: 2)
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

BASE_URL = "https://elefante-economico.github.io/elefante-economico"

# ============================
# GENERAR SITEMAP
# ============================

xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do

  # ----------------------------
  # 1) Página principal (index)
  # ----------------------------
  xml.url do
    xml.loc("#{BASE_URL}/")
    xml.lastmod(File.mtime("index.html").strftime("%Y-%m-%d")) if File.exist?("index.html")
    xml.changefreq("daily")
    xml.priority("1.0")
  end

  # ----------------------------
  # 2) Todos los posts
  # ----------------------------
  Dir.glob("posts/*.html").each do |file|
    xml.url do
      xml.loc("#{BASE_URL}/#{file}")
      xml.lastmod(File.mtime(file).strftime("%Y-%m-%d"))
      xml.changefreq("monthly")
      xml.priority("0.8")
    end
  end

  # ----------------------------
  # 3) El propio sitemap (opcional pero recomendado)
  # ----------------------------
  xml.url do
    xml.loc("#{BASE_URL}/sitemap.xml")
    xml.lastmod(Time.now.strftime("%Y-%m-%d"))
    xml.changefreq("weekly")
    xml.priority("0.5")
  end
end

output.close
puts "✔ Sitemap generado correctamente."
