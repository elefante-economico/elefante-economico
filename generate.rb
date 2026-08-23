require 'json'
require 'fileutils'

feed = JSON.parse(File.read("feed.json"))
entries = feed["feed"]["entry"]

FileUtils.mkdir_p("posts")

generated = []
discarded_no_alternate = []
auto_slugged = []
collisions = []

puts "=== Ejecutando Generación de posts ==="

entries.each do |entry|
  title = entry["title"]["$t"]
  links = entry["link"]

  # Buscar link alternativo
  alt = links.find { |l| l["rel"] == "alternate" }

  if alt.nil?
    discarded_no_alternate << title
    puts "Sin link alternativo: #{title}"
    next
  end

  # Extraer slug
  slug = alt["href"].split("/").last
  slug = slug.gsub(/\.html$/, "") if slug

  # Slug automático si está vacío
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

  # Colisión
  if File.exist?(filename)
    collisions << title
    puts "Colisión de slug (ya existe #{filename}): #{title}"
    next
  end

  # Contenido del post
  content = entry["content"]["$t"]
  fecha = entry["published"]["$t"][0..9]
  url = "https://elefante-economico.github.io/elefante-economico/posts/#{slug}.html"
  descripcion = content[0..150].gsub(/[\n\r]/, " ")

  # ============================
  # SEO + IA: HEAD COMPLETO
  # ============================

  head_content = <<~HTML
  <head>
    <meta charset="UTF-8">
    <title>#{title}</title>

    <!-- SEO -->
    <meta name="description" content="#{descripcion}">
    <meta name="author" content="Maxi Mozetic">
    <meta name="keywords" content="economía, desarrollo, desigualdad, matemáticas, filosofía, modelos económicos, IA, análisis">

    <!-- Canonical -->
    <link rel="canonical" href="#{url}">

    <!-- OpenGraph -->
    <meta property="og:title" content="#{title}">
    <meta property="og:description" content="#{descripcion}">
    <meta property="og:type" content="article">
    <meta property="og:url" content="#{url}">
    <meta property="og:site_name" content="El Elefante Económico">

    <!-- JSON-LD -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      "headline": "#{title}",
      "author": "Maxi Mozetic",
      "datePublished": "#{fecha}",
      "url": "#{url}",
      "publisher": {
        "@type": "Organization",
        "name": "El Elefante Económico"
      }
    }
    </script>
  </head>
  HTML

  # ============================
  # HTML COMPLETO DEL POST
  # ============================

  html = <<~HTML
  <!DOCTYPE html>
  <html lang="es">
  #{head_content}
  <body>
    <h1>#{title}</h1>
    <p><em>Publicado el #{fecha}</em></p>
    #{content}
  </body>
  </html>
  HTML

  # Guardar archivo
  File.write(filename, html)

  generated << title
  puts "Generado correctamente: #{title} → #{filename}"
end

# ============================
# RESUMEN FINAL
# ============================

puts "\n=== RESUMEN ==="
puts "Generados: #{generated.count}"
puts "Slugs automáticos: #{auto_slugged.count}"
puts "Sin link alternativo: #{discarded_no_alternate.count}"
puts "Colisiones: #{collisions.count}"
puts "✔ Generación de posts completado correctamente."
