#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  ##
  # The number of the current version.
  #
  def self.version_number
    major = 1
    minor = 0
    tiny  = 0
    pre   = nil

    string = [major, minor, tiny, pre].compact.join('.')
    Gem::Version.new string
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2018-07-20'
  end
end
