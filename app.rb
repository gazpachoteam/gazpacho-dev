require 'sinatra'
require "sinatra/reloader" if development?
require 'i18n'
require 'i18n/backend/fallbacks'
require 'dotenv/load'
require 'bundler/setup'
require 'kroniko'
require 'fileutils'

class EstudioSolicitado < Kroniko::Event; end

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

# Initialize file-based event store
store_dir = ENV.fetch('EVENT_STORE_DIR', File.join(__dir__, 'event_store'))
FileUtils.mkdir_p(store_dir) unless Dir.exist?(store_dir)
EVENT_STORE = Kroniko::EventStore.new(store_dir)

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
  EVENT_STORE.write(events: [EstudioSolicitado.new(
    data: {
      nombre: params[:nombre],
      email: params[:email],
      telefono: params[:telefono],
      comentarios: params[:comentarios]
    }
  )])

  redirect to('/estudio-ia?enviado=true#contacto')
end
