# encoding: utf-8

# Responde con posibles links que tengan relacion con lo que se esta hablando
#
#

require 'opengraph'
require 'rsemantic'

# Cantidad minima de palabras necesarias en una oracion para activar la
# busqueda de links
MSG_MIN_LEN = 15

# Modulo numerico para lanzar la rutina de Serializacion y LSA
THRESHOLD = 50

class MeRecuerda
  include Cinch::Plugin

  # Variable de Clase para compratir entre todos los servidores
  @@webs = {}

  def initialize(*args)
    super
  end

  match /https?:\/\/[^'"]+/, use_prefix: false, method: :capturar

  #   Armado del diccionario de equivalencias
  # - Analiza con opengraph la descripcion de un link y el titulo
  # - Obtiene el titulo, descripcion y si es posible el contenido
  # - Con la suma de las tres caracteristicas anteriores genera un item
  # - Almaceno al item en un hash y lo apunto a su url

  def capturar(m)
    # Obtengo las url y guardo la descripcion
    m.message.scan(/https?:\/\/[^'" #]+/).each do |url|
      url = URI.encode(url)
      resource = OpenGraph.fetch(url)

      next unless resource
      title = HTMLEntities.new.decode(resource.title)
      description = HTMLEntities.new.decode(resource.description)

      # uno titulo y descripcion para crear el item en relacion a la URL
      @@webs[title + ' ' + description] = url
    end
  end

  # Relaciona una conversacion a un link
  # Si el mensaje enviado es >= en largo a MSG_MIN_LEN busco un link relacionado
  # y lo envio, siempre y tenga al menos un 75% de acierto.
  def relacionar_link(m)
    if m.message.split(' ').length >= MSG_MIN_LEN

      if !@@web.empty? && @@web.length % THRESHOLD
        search = RSemantic::Search.new(@@webs.keys, verbose: false)

        # Obtengo el indice de matcheo mayor en relacion al mensaje
        max = search.search([m.message]).max

        # Obtengo la URL del item
        url = @@web[@@web.keys[search.index(max)]]

        rta = ['Me recordaste ', 'Me hiciste acrdar a',
               'Hace tiempo lei algo similar aca ',
               "Mm.. acá hablaban de eso "].sample + url

        m.reply(rta, true)
      end
    end
  end
end
