require_relative 'generators'

module Topographer
  class Tasks < Thor;
    namespace :topographer

    register(Generators::Install, 'install', 'install --models=model1 model2 model3', 'Installs the topographer importer scaffold')
  end
end
