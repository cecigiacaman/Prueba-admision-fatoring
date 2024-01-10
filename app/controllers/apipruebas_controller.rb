require 'net/http'
require 'json'
require 'date'

class ApipruebasController < ApplicationController
  before_action :set_apiprueba, except: %i[ index create update destroy ]

  def index
    print "Por favor, ingresa rut emisor: "
    rut_emisor = gets.chomp
    print "Por favor, ingresa rut deudor: "
    rut_deudor = gets.chomp
    print "Por favor, ingresa monto factura: "
    monto_factura = gets.chomp.to_i
    print "Por favor, ingresa folio: "
    folio = gets.chomp.to_i
    print "Por favor, ingresa fecha vencimiento: "
    fecha_vencimiento = gets.chomp

    factura = {
      rut_emisor: rut_emisor,
      rut_deudor: rut_deudor,
      monto_factura: monto_factura,
      folio: folio,
      fecha_vencimiento: fecha_vencimiento,
      api_key: 'pZX5rN8qAdgzCe0cAwpnQQtt'
    }

    cotizacion = cotizar_factura(factura[:rut_emisor], factura[:rut_deudor], factura[:monto_factura], factura[:folio], factura[:fecha_vencimiento], factura[:api_key])
    costos = calcular_costos(cotizacion)

    @apiprueba = Apiprueba.new(
      username: "Resultado de la cotización",
      string: "Costo de financiamiento: $#{costos[:costo_financiamiento]}, Giro a recibir: $#{costos[:giro_a_recibir]}, Excedentes: $#{costos[:excedentes]}"
    )

    render json: @apiprueba
  end

  def show
    render json: @apiprueba
  end

  def create
    @apiprueba = Apiprueba.new(apiprueba_params)

    if @apiprueba.save
      render json: @apiprueba, status: :created, location: @apiprueba
    else
      render json: @apiprueba.errors, status: :unprocessable_entity
    end
  end

  def update
    if @apiprueba.update(apiprueba_params)
      render json: @apiprueba
    else
      render json: @apiprueba.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @apiprueba.destroy!
  end

  private

  def set_apiprueba
    @apiprueba = Apiprueba.find(params[:id])
  end

  def apiprueba_params
    params.require(:apiprueba).permit(:username, :string)
  end

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
    if cotizacion && cotizacion['document_rate'] && cotizacion['commission'] && cotizacion['advance_percent']
      tasa_negocio = cotizacion['document_rate'].to_f / 100
      comision = cotizacion['commission'].to_f / 100
      anticipo_percent = cotizacion['advance_percent'].to_f / 100

      dias_plazo = (Date.parse('2024-02-09') - Date.parse('2024-01-10')).to_i + 1

      costo_financiamiento = (1000000 * anticipo_percent) * (tasa_negocio / 30.0 * dias_plazo)
      giro_a_recibir = (1000000 * anticipo_percent) - (costo_financiamiento + (1000000 * comision))
      excedentes = 1000000 - (1000000 * anticipo_percent)

      {
        costo_financiamiento: costo_financiamiento.round,
        giro_a_recibir: giro_a_recibir.round,
        excedentes: excedentes.round
      }
    else
      {
        error: 'La respuesta de la API no es válida o no contiene la información esperada.'
      }
    end
  end
end
