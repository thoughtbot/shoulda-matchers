module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    module Controller
      VALID_FORMATS = Dir.glob(File.join(File.dirname(__FILE__), 'formats', '*.rb')).map { |f| File.basename(f, '.rb') }.map(&:to_sym) # :doc:
      VALID_FORMATS.each {|f| require "shoulda/controller/formats/#{f}"}

      VALID_ACTIONS = [:index, :show, :new, :edit, :create, :update, :destroy] # :doc:
    end
  end
end


