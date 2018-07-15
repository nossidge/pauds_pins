#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  class Pin
    attr_accessor :title, :page, :jpg, :png_orig, :png_x320

    def initialize(args = {})
      @title     = args[:title]
      @page      = args[:page]
      @jpg       = args[:jpg]
      @png_orig  = args[:png_orig]
      @png_x320  = args[:png_x320]
    end

    def filename
      File.basename(jpg, '.jpg')
    end

    def jpg_filepath
      DIR_JPG + (filename.to_s + '.jpg')
    end

    def png_orig_filepath
      DIR_PNG_ORIG + (filename.to_s + '.png')
    end

    def png_x320_filepath
      DIR_PNG_X320 + (filename.to_s + '.png')
    end

    ############################################################################

    # This is the hash that is written to the JSON file
    def to_h
      {
        title:     title.to_s,
        filename:  filename.to_s,
        page:      page.to_s,
        jpg:       jpg.to_s,
        png_orig:  png_orig.to_s,
        png_x320:  png_x320.to_s
      }
    end

    def to_s
      to_h.to_s
    end

    # Using 'page' will sort by category, then filename
    def <=>(other)
      other.page <=> page
    end

    ############################################################################

    # Download the JPEG from the '@jpg' URL
    def download_jpg
      return jpg_filepath if jpg_filepath.exist?

      File.open(jpg_filepath, 'wb') do |f|
        f << URI(jpg).read
      end
      jpg_filepath
    end

    ############################################################################

    # Convert to PNG with transparent background
    def jpg_to_png
      return png_orig_filepath if png_orig_filepath.exist?

      command   = 'magick convert'
      operation = '-fuzz 3% -fill none -draw "color 0,0 floodfill"'
      input     = "\"#{jpg_filepath}\""
      output    = "\"#{png_orig_filepath}\""
      `#{command} #{operation} #{input} #{output}`

      png_orig_filepath
    end

    # Resize and compress the image
    def png_to_png_x320
      return png_x320_filepath if png_x320_filepath.exist?

      size      = 320
      command   = 'magick convert'
      operation = "-resize #{size}x#{size} -strip -quality 50%"
      input     = "\"#{png_orig_filepath}\""
      output    = "\"#{png_x320_filepath}\""
      `#{command} #{operation} #{input} #{output}`

      png_x320_filepath
    end

    ############################################################################

    def upload_png_x320(limit_with_sleep: false)
      return @png_x320 unless @png_x320.empty?
      @png_x320 = upload_png(
        png_x320_filepath, limit_with_sleep: limit_with_sleep
      )
    end

    def upload_png_orig(limit_with_sleep: false)
      return @png_orig unless @png_orig.empty?
      @png_orig = upload_png(
        png_orig_filepath, limit_with_sleep: limit_with_sleep
      )
    end

    ############################################################################

    private

    # Upload to Imgur
    # Need to sleep between requests so Imgur does not rate limit us
    # Limit is apparently one every 8 seconds
    # Also, 50 per minute.
    def upload_png(filepath, limit_with_sleep: false)
      sleep(10) if limit_with_sleep
      client = Imgur.new(IMGUR_CLIENT_ID)
      image = Imgur::LocalImage.new(filepath.to_s, title: title)
      uploaded = client.upload(image)
      uploaded.link #=> https://i.imgur.com/bBlMW3X.png
    end
  end
end
