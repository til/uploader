require 'rubygems'
require 'bundler/setup'
Bundler.setup :default
require 'goliath'

module Uploader; end

require 'uploader/too_large_error'
require 'uploader/length_required_error'
require 'uploader/unsupported_extension_error'
require 'uploader/success_message'
require 'uploader/renderer'

require 'uploader/config'
require 'uploader/request'
require 'uploader/registry'
require 'uploader/upload'
require 'uploader/target'
require 'uploader/parser'
require 'uploader/protector'
require 'uploader/route'
require 'uploader/server'
require 'erb'
