require 'json'
require 'fileutils'

FileUtils.mkdir_p('posts')

data = JSON.parse(File.read('feed.json'))
entries = data.dig('feed', 'entry') || []

sitemap_urls = []

entries.each do |entry|
  title = entry.dig('title', '$t') || 'Sin título'
  content = entry.dig('content', '$t') || ''
  published = entry.dig('published', '$t') || ''
  original_link = (entry['link'] || []).find { |l| l['rel'] == 'alternate' }&.dig('href') || ''
  categories = (entry['category'] || []).map { |c| c['term'] }.join(', ')

  slug = original_link.split('/').last&.sub('.html', '') || entry.dig('id', '$t').to_s
  slug = slug.gsub(/[^a-zA-Z0-9\-_]/, '')
  next if slug.empty?

  fecha = begin
    Time.parse(published).strftime('%d de %B de %Y')
  rescue
    published
  end

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
        body { font-family: "Segoe UI", Roboto, Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #222; }
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

# sitemap.xml
sitemap = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url><loc>https://elefante-economico.github.io/elefante-economico/</loc></url>
    #{sitemap_urls.map { |u| "<url><loc>#{u}</loc></url>" }.join("\n  ")}
  </urlset>
XML

File.write('sitemap.xml', sitemap)

puts "Generados #{entries.size} posts."
