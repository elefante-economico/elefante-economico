#!/usr/bin/env ruby

puts "=== Generando posts ==="
system("ruby generate.rb")

puts "\n=== Generando sitemap ==="
system("ruby sitemap.rb")

puts "\n=== Generando índice ==="
system("ruby index.rb")

puts "\n=== Todo listo ==="
