require 'json'
require_relative 'stock_report_error.rb'

class StockReport

  attr_accessor :config
  attr_accessor :key
  attr_accessor :stocks

  CONFIG_FILE_NAME = 'config.json'
  API_KEY_NAME = 'key'
  MESSAGE_CONFIG_NOT_FOUND = "Could not open config.json"
  MESSAGE_INVALID_JSON = "Invalid JSON syntax on config.json"
  MESSAGE_KEY_NOT_INFORMED = "API key was not informed. Set 'key' on config.json file"
  MESSAGE_STOCK_NOT_INFORMED = "You should inform at least one stock on config.json file"

  def generate_report
    begin
      read_config CONFIG_FILE_NAME
      parse_fields @config
      read_stocks
    rescue StockReportError => e
      puts e.message
    end
  end

  def read_config file_name
    # Read config file
    begin
      @config =  File.read(file_name)
    rescue
      raise StockReportError, MESSAGE_CONFIG_NOT_FOUND
    end
  end

  def parse_fields raw_text
    json = ""
    begin
      json = JSON.parse(raw_text)
    rescue => e
      puts e.message
      raise StockReportError, MESSAGE_INVALID_JSON
    end

    @key = json["key"]

    if @key.empty?
      raise StockReportError,  MESSAGE_KEY_NOT_INFORMED
    end

    @stocks = json["stocks"]

    if @stocks.empty?
      raise StockReportError, MESSAGE_STOCK_NOT_INFORMED
    end
  end

  def read_stocks

    # Get information for each company
    stocks.each do |stock|
      # Create class Stock and atts
      # Call api and retrieve values
      # Set values on Stock class
      puts stock
    end
  end
end
