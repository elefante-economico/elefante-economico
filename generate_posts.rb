require 'json'
require 'fileutils'
require 'time'

# Limpiamos y recreamos la carpeta posts
FileUtils.rm_rf('posts')
FileUtils.mkdir_p('posts')

data = JSON.parse(File.read('feed.json'))
entries = data.dig('feed', 'entry') || []

sitemap_urls = []

entries.each do |entry|
  content = entry.dig('content', '$t') || ''
  published = entry.dig('published', '$t') || ''
  original_link = (entry['link'] || []).find { |l| l['rel'] == 'alternate' }&.dig('href') || ''
  categories = (entry['category'] || []).map { |c| c['term'] }.join(', ')

  # === INTELIGENCIA PARA TÍTULOS VACÍOS ===
  title = entry.dig('title', '$t')
  if title.nil? || title.strip.empty?
    # Limpiamos el HTML del contenido para extraer texto plano
    texto_plano = content.gsub(/<\/?[^>]*>/, '').gsub(/\s+/, ' ').strip
    if !texto_plano.empty?
      # Tomamos los primeros 55 caracteres y cortamos en la última palabra completa
      extracto = texto_plano[0...55]
      extracto = extracto.rpartition(' ').first unless extracto.rpartition(' ').first.empty?
      title = "#{extracto}..."
    else
      fecha_corta = published.split('T').first rescue 'sin-fecha'
      title = "Artículo sin título (#{fecha_corta})"
    end
  end
  # ========================================

  # Obtener slug base del link o del ID
  raw_slug = original_link.split('/').last&.sub('.html', '') || entry.dig('id', '$t').to_s

  # Normalización segura de acentos y caracteres
  slug = raw_slug.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  slug = slug.unicode_normalize(:nfd).gsub(/\p{M}/, '')
  slug = slug.downcase.strip.gsub(/[^a-z0-9\-_]/, '-')
  slug = slug.gsub(/-+/, '-')

  if slug.empty? || slug == '-'
    fallback_id = entry.dig('id', '$t').to_s.split('-').last
    slug = "articulo-#{fallback_id}"
  end

  fecha = begin
    Time.parse(published).strftime('%d de %B de %Y')
  rescue
    published
  end

  # Plantilla HTML individual para cada post
  html = <<~HTML
    ---
    ---
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>#{title} — El Elefante Económico</title>
      <meta name="description" content="#{title}">
      <link rel="canonical" href="#{original_link}">
      <meta property="og:title" content="#{title}">
      <meta property="og:type" content="article">
      <meta property="og:url" content="https://elefante-economico.github.io/elefante-economico/posts/#{slug}.html">
      <style>
        body { font-family: "Segoe UI", Roboto, Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #222; line-height: 1.6; }
        a { color: #0056b3; }
        .meta { color: #666; font-size: 0.9rem; margin-bottom: 30px; }
      </style>
    </head>
    <body>
      <p><a href="../">← Volver al índice</a></p>
      <h1>#{title}</h1>
      <p class="meta">#{fecha} · #{categories}</p>
      <article>#{content}</article>
      <hr>
      <p><a href="#{original_link}" target="_blank">Ver en el blog original</a></p>
    </body>
    </html>
  HTML

  File.write("posts/#{slug}.html", html)
  sitemap_urls << "https://elefante-economico.github.io/elefante-economico/posts/#{slug}.html"
end

# Generación del índice principal (aplicando exactamente la misma lógica)
index_items = entries.map do |entry|
  content = entry.dig('content', '$t') || ''
  published = entry.dig('published', '$t') || ''
  original_link = (entry['link'] || []).find { |l| l['rel'] == 'alternate' }&.dig('href') || ''
  
  title = entry.dig('title', '$t')
  if title.nil? || title.strip.empty?
    texto_plano = content.gsub(/<\/?[^>]*>/, '').gsub(/\s+/, ' ').strip
    if !texto_plano.empty?
      extracto = texto_plano[0...55]
      extracto = extracto.rpartition(' ').first unless extracto.rpartition(' ').first.empty?
      title = "#{extracto}..."
    else
      fecha_corta = published.split('T').first rescue 'sin-fecha'
      title = "Artículo sin título (#{fecha_corta})"
    end
  end
  
  raw_slug = original_link.split('/').last&.sub('.html', '') || entry.dig('id', '$t').to_s
  slug = raw_slug.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  slug = slug.unicode_normalize(:nfd).gsub(/\p{M}/, '')
  slug = slug.downcase.strip.gsub(/[^a-z0-9\-_]/, '-')
  slug = slug.gsub(/-+/, '-')
  
  if slug.empty? || slug == '-'
    fallback_id = entry.dig('id', '$t').to_s.split('-').last
    slug = "articulo-#{fallback_id}"
  end

  fecha_formateada = begin
    Time.parse(published).strftime('%Y-%m-%d')
  rescue
    published
  end

  %{<li><a href="posts/#{slug}.html">#{title}</a> — #{fecha_formateada}</li>}
end.join("\n")

index_html = <<~HTML
  <!DOCTYPE html>
  <html lang="es">
  <head>
    <meta charset="UTF-8">
    <title>El Elefante Económico — Índice de artículos</title>
    <meta name="description" content="Índice completo de artículos publicados en El Elefante Económico.">
    <meta name="author" content="Maxi Mozetic">
    <link rel="canonical" href="https://elefante-economico.github.io/elefante-economico/">
  </head>
  <body>
  <h1>El Elefante Económico — Índice</h1>
  <ul>
  #{index_items}
  </ul>
  </body></html>
HTML

File.write('index.html', index_html)

# sitemap.xml
sitemap = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url><loc>https://elefante-economico.github.io/elefante-economico/</loc></url>
    #{sitemap_urls.map { |u| "<url><loc>#{u}</loc></url>" }.join("\n  ")}
  </urlset>
XML

File.write('sitemap.xml', sitemap)

puts "Generados #{entries.size} posts y actualizado el índice correctamente con extractos inteligentes."
