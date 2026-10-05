#!/usr/bin/env ruby

def run(name, cmd)
  puts "\n=== #{name} ==="
  system(cmd)
end

run("Generar posts, índice y sitemap", "ruby generate_posts.rb")

puts "\nPipeline completado."
