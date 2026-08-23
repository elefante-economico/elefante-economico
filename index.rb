#!/usr/bin/env ruby
require 'json'

# ============================
# CARGA DEL FEED
# ============================

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

# ============================
# EXTRAER POSTS
# ============================

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

# ============================
# ORDENAR POR FECHA DESCENDENTE
# ============================

posts = posts.sort_by { |p| p[:date] }.reverse

# ============================
# SEO + IA: HEAD COMPLETO
# ============================

head_content = <<~HTML
<head>
  <meta charset="UTF-8">
  <title>El Elefante Económico — Índice de artículos</title>

  <!-- SEO -->
  <meta name="description" content="Índice completo de artículos publicados en El Elefante Económico.">
  <meta name="author" content="Maxi Mozetic">
  <meta name="keywords" content="economía, desarrollo, desigualdad, matemáticas, filosofía, modelos económicos, IA, análisis">

  <!-- Canonical -->
  <link rel="canonical" href="https://elefante-economico.github.io/elefante-economico/">

  <!-- OpenGraph -->
  <meta property="og:title" content="El Elefante Económico — Índice">
  <meta property="og:description" content="Listado completo de artículos publicados.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://elefante-economico.github.io/elefante-economico/">
  <meta property="og:site_name" content="El Elefante Económico">

  <!-- JSON-LD WebSite -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "El Elefante Económico",
    "url": "https://elefante-economico.github.io/elefante-economico/",
    "publisher": {
      "@type": "Organization",
      "name": "El Elefante Económico"
    }
  }
  </script>
</head>
HTML

# ============================
# GENERAR HTML DEL ÍNDICE
# ============================

html = []
html << "<!DOCTYPE html>"
html << "<html lang=\"es\">"
html << head_content
html << "<body>"
html << "<h1>El Elefante Económico — Índice</h1>"
html << "<ul>"

posts.each do |p|
  html << "<li><a href=\"posts/#{p[:slug]}.html\">#{p[:title]}</a> — #{p[:date][0..9]}</li>"
end

html << "</ul>"
html << "</body></html>"

# ============================
# GUARDAR ARCHIVO
# ============================

begin
  File.write("index.html", html.join("\n"))
  puts "✔ Índice generado correctamente con #{posts.count} posts."
rescue => e
  puts "✖ ERROR: No se pudo escribir index.html — #{e.message}"
  exit(1)
end
