#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'json'

require 'open-uri'
require 'net/http'
require 'net/https'

require 'nokogiri'
require 'imgur'

require_relative 'pauds_pins/pin'
require_relative 'pauds_pins/pin_collection'
require_relative 'pauds_pins/version'

IMGUR_CLIENT_ID = ENV['IMGUR_CLIENT_ID']

DIR_ROOT           = Pathname(__FILE__).parent.parent
DIR_DATA           = DIR_ROOT + 'data'
DIR_JPG            = DIR_DATA + 'jpg'
DIR_PNG_ORIG       = DIR_DATA + 'png_orig'
DIR_PNG_COMPRESSED = DIR_DATA + 'png_compressed'
FILE_JSON          = DIR_DATA + 'pins.json'

[DIR_DATA, DIR_JPG, DIR_PNG_ORIG, DIR_PNG_COMPRESSED].each do |i|
  FileUtils.makedirs(i) unless i.exist?
end
