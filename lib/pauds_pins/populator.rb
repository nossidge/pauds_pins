#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  class Populator
    attr_reader :pins

    def initialize(pin_collection)
      @pins = pin_collection
    end

    def download_jpg
      pins.each_download_jpg
      pins.save
    end

    def jpg_to_png
      pins.each_jpg_to_png
      pins.save
    end

    def compress_as_png_x320
      pins.each_compress_as_png_x320
      pins.save
    end

    # This will error after 50 uploads in an hour.
    # Will automatically save to file.
    def upload_png_x320
      pins.upload_till_error_png_x320
    end

    # This will error after 50 uploads in an hour.
    # Will automatically save to file.
    def upload_png_orig
      pins.upload_till_error_png_orig
    end
  end
end
