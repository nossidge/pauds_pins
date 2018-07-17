#!/usr/bin/env ruby
# frozen_string_literal: true

module PaudsPins
  class PinCollection
    include Enumerable

    attr_reader :pins

    def initialize
      @pins = []
      scrape_if_necessary
    end

    def each
      pins.each do |pin|
        yield pin
      end
    end

    ############################################################################

    # Load pin collection data from JSON file
    def load
      from_file = JSON.parse(
        FILE_JSON.read(encoding: 'UTF-8'),
        symbolize_names: true
      )
      @pins = from_file.map { |i| Pin.new(i) }
    end

    # Save the contents of @pins as a json file
    def save(filepath = FILE_JSON)
      hash_array = pins.sort.reverse.map(&:to_h)
      json_string = JSON.pretty_generate(hash_array)
      File.open(filepath, 'w:UTF-8') do |f|
        f.puts json_string
      end
    end

    ############################################################################

    # Download all JPGs en-masse using multithreading
    def each_download_jpg
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.download_jpg
        end
      end.each(&:join)
    end

    # Convert each JPG to a PNG
    # I'm using multithreading, but maybe it's not necessary...
    def each_jpg_to_png
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.jpg_to_png
        end
      end.each(&:join)
    end

    # Compress each PNG to a smaller file
    def each_compress_as_png_x320
      pins.map do |pin|
        Thread.new(pin) do |pin|
          pin.png_to_png_x320
        end
      end.each(&:join)
    end

    ############################################################################

    def upload_till_error_png_orig
      upload_till_error(:next_upload_png_orig)
    end

    def upload_till_error_png_x320
      upload_till_error(:next_upload_png_x320)
    end

    ############################################################################

    private

    # This will error, either if we are over the 50 image / hour Imgur limit,
    # or if there are no more PNG files to upload
    def upload_till_error(method_name)
      loop do
        send(method_name)
        save
        sleep(10)
      end
    end

    # Upload the first pin that does not have a url
    def next_upload_png_orig
      pin = pins.find { |i| i.png_orig.empty? }
      pin.upload_png_orig
    end

    # Upload the first pin that does not have a url
    def next_upload_png_x320
      pin = pins.find { |i| i.png_x320.empty? }
      pin.upload_png_x320
    end

    ############################################################################

    # Don't scrape if the JSON file already exists
    def scrape_if_necessary
      return load if FILE_JSON.exist?
      @pins = get_image_pins
    end

    # Scrape the wordpress site to get metadata for all the pins
    def get_image_pins
      [].tap do |output|
        get_catalogue_pages.map do |url|
          Thread.new(output, url) do |output, url|
            output << scrape_from_category_page(url)
          end
        end.each(&:join)
      end.flatten.sort
    end

    # Return the URL of each category
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
      category = page.css('h1.entry-title').text
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
          category: category,
          page: page_urls[i],
          jpg: jpg_urls[i]
        )
      end
    end
  end
end
