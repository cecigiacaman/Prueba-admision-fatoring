require 'net/http'
require 'date'
require 'json'
def cotizar_factura(rut_emisor, rut_deudor, monto_factura, folio, fecha_vencimiento, api_key)
    endpoint = 'https://chita.cl/api/v1/pricing/simple_quote'
    uri = URI(endpoint)
    
    params = {
      client_dni: rut_emisor,
      debtor_dni: rut_deudor,
      document_amount: monto_factura,
      folio: folio,
      expiration_date: fecha_vencimiento
    }
  
    uri.query = URI.encode_www_form(params)
  
    request = Net::HTTP::Get.new(uri)
    request['X-Api-Key'] = api_key
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    JSON.parse(response.body)
  end
  
  def calcular_costos(cotizacion)
    tasa_negocio = cotizacion['document_rate'] / 100
    comision = cotizacion['commission'] / 100
    anticipo_percent = cotizacion['advance_percent'] / 100
  
    dias_plazo = (Date.parse('2024-02-09') - Date.parse('2024-01-10')).to_i + 1
  
    costo_financiamiento = (1000000 * anticipo_percent) * (tasa_negocio / 30.0 * dias_plazo)
    giro_a_recibir = (1000000 * anticipo_percent) - (costo_financiamiento + (1000000 * comision))
    excedentes = 1000000 - (1000000 * anticipo_percent)
  
    {
      costo_financiamiento: costo_financiamiento.round(2),
      giro_a_recibir: giro_a_recibir.round(2),
      excedentes: excedentes.round(2)
    }
  end
  
  # Datos de la factura
  print "Por favor, ingresa rut emisor: "
  rut_emisor = gets.chomp
  print "Por favor, ingresa rut deudor: "
  rut_deudor = gets.chomp
  print "Por favor, ingresa monto factura "
  monto_factura = gets.chomp
  print "Por favor, ingresa folio:  "
  folio = gets.chomp
  print "Por favor, ingresa fecha vencimiento:  "
  fecha_vencimiento = gets.chomp
  api_key = 'pZX5rN8qAdgzCe0cAwpnQQtt'
  
  # Cotizar la factura
  cotizacion = cotizar_factura(rut_emisor, rut_deudor, monto_factura, folio, fecha_vencimiento, api_key)
  
  # Calcular costos
  costos = calcular_costos(cotizacion)
  
  # Mostrar resultados
  puts "Costo de financiamiento: $#{costos[:costo_financiamiento]}"
  puts "Giro a recibir: $#{costos[:giro_a_recibir]}"
  puts "Excedentes: $#{costos[:excedentes]}"