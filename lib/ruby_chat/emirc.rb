=begin
require 'bundler'
Bundler.setup :default

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/callbacks'
require 'active_support/deprecation'
require 'active_support/concern'
require 'active_support/core_ext/array/extract_options'
require 'eventmachine'
require 'forwardable'
require 'set'
=end


  module IRC
    autoload :Client,     'emirc/client'
    #autoload :Dispatcher, 'emirc/dispatcher'
    autoload :Commands,   'emirc/commands'
    autoload :Responses,  'emirc/responses'
  end
