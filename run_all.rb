#!/usr/bin/env ruby

def run(name, cmd)
  puts "\n=== #{name} ==="
  system(cmd)
end

run("Generar posts", "ruby generate.rb")
run("Generar sitemap", "ruby sitemap.rb")
run("Generar índice", "ruby index.rb")

puts "\nPipeline completado."
