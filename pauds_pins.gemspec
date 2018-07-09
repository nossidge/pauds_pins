#!/usr/bin/env ruby
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pauds_pins/version.rb'

Gem::Specification.new do |s|
  s.name          = 'pauds_pins'
  s.authors       = ['Paul Thompson']
  s.email         = ['nossidge@gmail.com']

  s.homepage      = 'https://github.com/nossidge/pauds_pins'
  s.summary       = "Paud's Pins image files"
  s.description   = <<~DESC.tr("\n", ' ')
    Scrape the pin images from [pauds_pins.wordpress.com], convert to PNG with
    background transparency, compress to smaller PNG, upload to Imgur. Store
    a JSON file containing metadata and Imgur URLs.
  DESC

  s.version       = PaudsPins.version_number
  s.date          = PaudsPins.version_date
  s.license       = 'GPL-3.0'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_runtime_dependency('imgur',    '~> 0.0', '>= 0.0.4')
  s.add_runtime_dependency('nokogiri', '~> 1.8', '>= 1.8.0')
end
