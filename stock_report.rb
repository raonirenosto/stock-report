require 'json'
require 'net/http'
require 'date'
require_relative 'stock_report_error.rb'
require_relative 'day_trade.rb'

class StockReport

  attr_accessor :config
  attr_accessor :key
  attr_accessor :stocks

  CONFIG_FILE_NAME = 'config.json'
  MESSAGE_CONFIG_NOT_FOUND = "Could not open config.json"
  MESSAGE_INVALID_JSON = "Invalid JSON syntax on config.json"
  MESSAGE_KEY_NOT_INFORMED = "API key was not informed. Set 'key' on config.json file"
  MESSAGE_STOCK_NOT_INFORMED = "You should inform at least one stock on config.json file"
  MESSAGE_API_CALL_ERROR = "An error has occured while acessing API"

  def generate_report
    begin
      read_config CONFIG_FILE_NAME
      parse_fields @config
      print_stock_report
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

  def call_api url, connection
    begin
    uri = URI(url)

    response = connection.get_response(uri)

    if response.code != 200
      raise StockReportError, MESSAGE_API_CALL_ERROR
    end

    # Check for errors returned by the API
    json = JSON.parse(response.body)


    if !json["Error Message"].empty?
      raise StockReportError, MESSAGE_API_CALL_ERROR
    end
    rescue => e
      puts e.message
    end
    return json
  end

  def print_stock_report
    # Get information for each company
    stocks.each do |stock|
      # Generate URL for get stock information
      url = generate_api_url stock

      # Get information from API
      api_result = call_api url, Net::HTTP

      # Get the last 5 work days
      working_days = last_5_working_days Date.today

      # Extract API result
      daily_trade = extract_information_from_json api_result, working_days

      # Print daily trade
      puts daily_trade_report stock, daily_trade
    end
  end

  def daily_trade_report symbol, daily_trade
    daily_report = ""

    daily_report << build_header(symbol)

    daily_report << "\n\n"

    # Build daily trade box
    daily_trade.each do |day_trade|

      # Print date header
      daily_report << "DATE: #{day_trade.date.strftime('%d/%m/%Y')}\n"

      # Print top section
      daily_report << "".rjust(19,"-") + "\n"

      # Print open price
      daily_report << price_line('OPEN', day_trade.open_price) + "\n"

      # Print close price
      daily_report << price_line('CLOSE', day_trade.close_price) + "\n"

      # Print high price
      daily_report << price_line('HIGH', day_trade.higher_price) + "\n"

      # Print low price
      daily_report << price_line('LOW', day_trade.lower_price) + "\n"

      # Print bottom section
      daily_report << "".rjust(19,"-") + "\n\n"
    end

    # Build footer
    daily_report << "".center(100,"*") + "\n\n\n"

    return daily_report
  end

  def build_header symbol
    return " LAST 5 DAYS BUSINESS REPORT FOR #{symbol} ".center(100,"*")
  end

  # Mount price column
  def price_line label, price
    price = "R$ %0.2f" % [price]
    return  "#{label}:".ljust(11) + price
  end
end
