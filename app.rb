require 'sinatra'
require "sinatra/reloader" if development?
require 'i18n'
require 'i18n/backend/fallbacks'

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

before do
  I18n.locale = params[:locale] || get_default_locale
end

get '/' do
  p @env["HTTP_ACCEPT_LANGUAGE"][0,2]
  erb :home
end
