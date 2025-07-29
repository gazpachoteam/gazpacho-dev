require 'sinatra'
require "sinatra/reloader" if development?
require 'i18n'
require 'i18n/backend/fallbacks'
require 'dotenv/load'
require 'pony'

helpers do
  def get_default_locale
    @env["HTTP_ACCEPT_LANGUAGE"][0,2] || I18n.default_locale
  end
end

I18n.available_locales = [:en, :es]
I18n.default_locale = :es
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
I18n.backend.load_translations

# Configure Pony SMTP settings if environment variables are present
if ENV['SMTP_ADDRESS']
  Pony.options = {
    via: :smtp,
    via_options: {
      address:              ENV['SMTP_ADDRESS'],
      port:                 ENV['SMTP_PORT'] || '587',
      enable_starttls_auto: true,
      user_name:            ENV['SMTP_USER'],
      password:             ENV['SMTP_PASSWORD'],
      authentication:       :plain,
      domain:               ENV['SMTP_DOMAIN'] || 'localhost'
    }
  }
end

before do
  I18n.locale = params[:locale] || get_default_locale
end

get '/' do
  erb :home
end

get '/estudio-ia' do
  erb :estudio_ia
end

post '/estudio-ia/contact' do
  nombre = params[:nombre]
  email  = params[:email]
  telefono = params[:telefono]
  comentarios = params[:comentarios]

  Pony.mail(
    to: 'info@gazpacho.dev',
    from: email || 'web@gazpacho.dev',
    subject: "Contacto Cooperativa - #{nombre}",
    body: <<~BODY
      Nombre de la cooperativa: #{nombre}
      Email: #{email}
      Teléfono: #{telefono}
      Comentarios:
      #{comentarios}
    BODY
  )

  redirect to('/estudio-ia?enviado=true#contacto')
end
