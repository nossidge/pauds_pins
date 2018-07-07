#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  class PinCollection
    include Enumerable

    attr_reader :pins

    def initialize
      @pins = []
      load if FILE_JSON.exist?
    end

    def each
      yield pins
    end

    # Save the contents of @pins as a json file
    def save(filepath = FILE_JSON)
      hash_array = pins.map(&:to_h)
      json_string = JSON.pretty_generate(hash_array)
      File.open(filepath, 'w:UTF-8') do |f|
        f.puts json_string
      end
    end

    # Scrape the wordpress site to get metadata for all the pins
    def scrape
      return load if FILE_JSON.exist?
      @pins = get_image_pins
    end

    # Load from file to prevent unnecessary gets
    def load
      from_file = JSON.parse(
        FILE_JSON.read(encoding: 'UTF-8'),
        symbolize_names: true
      )
      @pins = from_file.map { |i| Pin.new(i) }
    end

    # Downloading all JPGs en-masse using multithreading
    def each_download_jpg
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.download_jpg
        end
      end.each(&:join)
    end

    def each_jpg_to_png
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.jpg_to_png
        end
      end.each(&:join)
    end

    def each_compress_png
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.compress_png
        end
      end.each(&:join)
    end

    def upload_till_error_png_compressed
      upload_till_error(:next_upload_png_compressed)
    end

    def upload_till_error_png_orig
      upload_till_error(:next_upload_png_orig)
    end

    private

    def upload_till_error(method_name)
      loop do
        pins.send(method_name)
        pins.save
        sleep(10)
      end
    end

    # Find the first pin that does not have a url
    # Upload it
    def next_upload_png_compressed
      pin = pins.find { |i| i.png_url_compressed.empty? }
      pin.upload_png_compressed
    end

    def next_upload_png_orig
      pin = pins.find { |i| i.png_url_orig.empty? }
      pin.upload_png_orig
    end

    def get_image_pins
      [].tap do |output|
        get_catalogue_pages.map do |url|
          Thread.new(output, url) do |output, url|
            output << scrape_from_category_page(url)
          end
        end.each(&:join)
      end.flatten.sort
    end

    def get_catalogue_pages
      url = 'https://paudspins.wordpress.com/the-badges/'
      page = Nokogiri::HTML open(url)
      links = page.css('ul li span a')
      links.map { |a| a['href'] }
    end

    # Extract image data from the category page
    # This is the final of the scrape methods
    def scrape_from_category_page(url)
      page = Nokogiri::HTML open(url)
      elements = page.css('div.entry-content a')
      page_urls = elements.map { |i| i['href'] }
      elements = page.css('div.entry-content img')
      jpg_urls = elements.map { |i| i['data-orig-file'] }
      titles = elements.map { |i| i['data-image-title'] }

      # There should be the same number of elements
      counts = [page_urls.count, jpg_urls.count, titles.count]
      raise StandardError unless counts.uniq.count == 1

      # Create a new Pin for each
      titles.count.times.map do |i|
        Pin.new(
          title: titles[i],
          page_url: page_urls[i],
          jpg_url: jpg_urls[i]
        )
      end
    end
  end
end
