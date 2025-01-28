# frozen_string_literal: true

require 'playwright'

# Definir la URL del archivo (tu página estática)
file_url = 'http://localhost:8080/index.html' # Cambia esto si estás usando otro servidor

# El margen en píxeles que deseas agregar (ajusta según sea necesario)
MARGIN = 10

# Iniciar Playwright
Playwright.create do |p|
  browser = p.chromium.launch(headless: true) # headless: true para no mostrar el navegador
  page = browser.new_page

  # Cargar la página
  page.goto(file_url)

  # Esperar hasta que el selector dinámico #prCount esté visible
  page.wait_for_selector('#prCount', timeout: 10_000) # Esperar hasta 10 segundos

  # Obtener las coordenadas y dimensiones del contenedor (.container)
  container = page.query_selector('.container')
  box = container.bounding_box

  # Asegúrate de que el contenedor tenga dimensiones válidas
  if box
    # Agregar un margen hacia adentro, reduciendo el tamaño del área de captura
    clip_box = {
      x: box[:x] + MARGIN,  # Mover la captura hacia la derecha
      y: box[:y] + MARGIN,  # Mover la captura hacia abajo
      width: box[:width] - 2 * MARGIN, # Reducir el ancho para agregar margen
      height: box[:height] - 2 * MARGIN # Reducir la altura para agregar margen
    }

    # Tomar la captura de pantalla solo del contenedor con el margen hacia adentro
    page.screenshot(path: 'preview-image.png', clip: clip_box)
  end

  # Cerrar el navegador
  browser.close
end

