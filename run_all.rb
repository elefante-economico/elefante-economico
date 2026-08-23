#!/usr/bin/env ruby

def run_step(name, command)
  puts "\n=== Ejecutando #{name} ==="
  success = system(command)

  if success
    puts "✔ #{name} completado correctamente."
  else
    puts "✖ ERROR: #{name} falló."
    puts "Deteniendo pipeline."
    exit(1)
  end
end

run_step("Generación de posts", "ruby generate.rb")
run_step("Generación de sitemap", "ruby sitemap.rb")
run_step("Generación de índice", "ruby index.rb")

puts "\n=== Pipeline completado sin errores ==="
puts "Todo listo para subir a GitHub Pages."

