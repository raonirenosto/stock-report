require 'json'
require_relative 'stock_report_error.rb'
require_relative 'day_trade.rb'

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

  def last_5_working_days date
    last_working_days = []
    while last_working_days.size < 5
      # Add dates only if is not Sunday or Satarday
      if date.wday > 0 && date.wday < 6
        last_working_days << date
      end
      date = date.prev_day
    end
    return last_working_days
  end

  def generate_api_url stock_symbol
    api_root = "https://www.alphavantage.co/query"
    api_function = "function=TIME_SERIES_DAILY_ADJUSTED"
    stock_symbol = "symbol=#{stock_symbol}.SAO" #São Paulo Market
    api_key = "apikey=#{@key}"

    api_url = "#{api_root}?#{api_function}&#{stock_symbol}&#{api_key}"
  end

  def extract_information_from_json json, dates
    section = json["Time Series (Daily)"]

    daily_trade = []
    dates.each do |date|
      date_section = section[date.strftime("%Y-%m-%d")]
      day_trade = DayTrade.new
      day_trade.date = date
      day_trade.open_price = date_section["1. open"].to_f
      day_trade.higher_price = date_section["2. high"].to_f
      day_trade.lower_price = date_section["3. low"].to_f
      day_trade.close_price = date_section["4. close"].to_f
      daily_trade << day_trade
    end
    return daily_trade
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
