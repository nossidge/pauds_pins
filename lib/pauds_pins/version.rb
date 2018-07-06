#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  ##
  # The number of the current version.
  #
  def self.version_number
    major = 0
    minor = 0
    tiny  = 1
    pre   = 'pre'

    string = [major, minor, tiny, pre].compact.join('.')
    Gem::Version.new string
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2018-07-05'
  end
end
