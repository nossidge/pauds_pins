#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  class Pin
    attr_reader(
      :title,
      :filename,
      :page_url,
      :jpg_url,
      :png_url_orig,
      :png_url_compressed
    )

    def initialize(
      title:,
      filename:,
      page_url:,
      jpg_url:,
      png_url_orig:,
      png_url_compressed:
    )
      @title              = title
      @filename           = filename
      @page_url           = page_url
      @jpg_url            = jpg_url
      @png_url_orig       = png_url_orig
      @png_url_compressed = png_url_compressed
    end

    def filename
      return @filename unless @filename.empty?
      uri = URI(jpg_url)
      @filename = File.basename(uri.path, '.jpg')
    end

    def jpg_filepath
      DIR_JPG + (filename.to_s + '.jpg')
    end

    def png_orig
      DIR_PNG_ORIG + (filename.to_s + '.png')
    end

    def png_compressed
      DIR_PNG_COMPRESSED + (filename.to_s + '.png')
    end

    def to_h
      {
        title:              title.to_s,
        filename:           filename.to_s,
        page_url:           page_url.to_s,
        jpg_url:            jpg_url.to_s,
        png_url_orig:       png_url_orig.to_s,
        png_url_compressed: png_url_compressed.to_s
      }
    end

    def to_s
      to_h.to_s
    end

    # Sort to keep the categories together
    def <=>(other)
      other.page_url <=> page_url
    end

    def download_jpg
      uri = URI(jpg_url)
      @filename = File.basename(uri.path).sub(/.jpg$/, '')

      return jpg_filepath if jpg_filepath.exist?

      File.open(jpg_filepath, 'wb') do |f|
        f << uri.read
      end
      jpg_filepath
    end

    # Convert to PNG with transparent background
    def jpg_to_png
      return png_orig if png_orig.exist?
      `magick convert #{jpg_filepath} -fuzz 3% -transparent white #{png_orig}`
      png_orig
    end

    # Resize and compress the image
    def compress_png
      return png_compressed if png_compressed.exist?
      size      = 320
      command   = 'magick convert'
      operation = "-resize #{size}x#{size} -strip -quality 50%"
      input     = "\"#{png_orig}\""
      output    = "\"#{png_compressed}\""
      `#{command} #{operation} #{input} #{output}`
      png_compressed
    end

    def upload_png_compressed(limit_with_sleep: false)
      return @png_url_compressed unless @png_url_compressed.empty?
      @png_url_compressed = upload_png(png_compressed, limit_with_sleep: false)
    end

    def upload_png_orig(limit_with_sleep: false)
      return @png_url_orig unless @png_url_orig.empty?
      @png_url_orig = upload_png(png_orig, limit_with_sleep: false)
    end

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
