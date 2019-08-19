require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../stock_report.rb'

class StockReportTest < Minitest::Spec
  attr_accessor :report

  def setup
    @report = StockReport.new
  end

  def test_read_config_file_not_found
    begin
      @report.read_config "not_a_valid_name"
    rescue => e
      assert_equal "Could not open config.json", e.message
    end
  end

  def test_parse_fields_invalid_json
    begin
      @report.parse_fields 'not_a_valid_json'
    rescue => e
      assert_equal "Invalid JSON syntax on config.json", e.message
    end
  end

  def test_parse_fields_key_not_informed
    begin
      @report.parse_fields '{"key": ""}'
    rescue => e
      assert_equal "API key was not informed. Set 'key' on config.json file", e.message
    end
  end

  def test_parse_fields_success
    @report.parse_fields '{"key":"123","stocks":["PETR4"]}'

    assert_equal "123", @report.key
    assert_equal 1, @report.stocks.size
  end

  def test_last_5_working_days_on_week_day
    last_5_working_days = @report.last_5_working_days Date.new(2019,8,5) #monday
    assert_equal Date.new(2019,8,5), last_5_working_days[0]
    assert_equal Date.new(2019,8,2), last_5_working_days[1]
    assert_equal Date.new(2019,8,1), last_5_working_days[2]
    assert_equal Date.new(2019,7,31), last_5_working_days[3]
    assert_equal Date.new(2019,7,30), last_5_working_days[4]
  end

  def test_last_5_working_days_not_on_week_day
    last_5_working_days = @report.last_5_working_days Date.new(2019,8,4) #sunday
    assert_equal Date.new(2019,8,2), last_5_working_days[0]
    assert_equal Date.new(2019,8,1), last_5_working_days[1]
    assert_equal Date.new(2019,7,31), last_5_working_days[2]
    assert_equal Date.new(2019,7,30), last_5_working_days[3]
    assert_equal Date.new(2019,7,29), last_5_working_days[4]
  end

  def test_generate_api_url
    correct_url = "https://www.alphavantage.co/query?" +
      "function=TIME_SERIES_DAILY_ADJUSTED" +
      "&symbol=PETR4.SAO&apikey=123"

    @report.parse_fields '{"key":"123","stocks":["PETR4"]}'
    url_to_assert = @report.generate_api_url "PETR4"

    assert_equal correct_url, url_to_assert
  end

  def test_extract_information_from_json
    json_data = JSON.parse(File.read('api_return.json'))
    dates = @report.last_5_working_days Date.new(2019,8,9)

    daily_trade = @report.extract_information_from_json(json_data,dates)

    day_trade1 = daily_trade[0]

    assert_equal 26.30, day_trade1.open_price
    assert_equal 26.29, day_trade1.close_price
    assert_equal 26.69, day_trade1.higher_price
    assert_equal 26.10, day_trade1.lower_price
    assert_equal Date.new(2019,8,9), day_trade1.date

    assert_equal 5, daily_trade.size
  end

  def test_call_to_api_result_not_200
    begin
      connection = stub()
      response = stub()
      response.stubs(:code).returns(404)
      connection.stubs(:get_response).returns(response)
      @report.call_api "any_url", connection
    rescue => e
      assert_equal "An error has occured while acessing API", e.message
    end
  end

  def test_call_to_api_result_api_error
    begin
      connection = stub()
      response = stub()
      response.stubs(:code).returns(200)
      response.stubs(:body).returns('{"Error Message": "Invalid API"}')
      connection.stubs(:get_response).returns(response)
      @report.call_api "any_url", connection
    rescue => e
      assert_equal "An error has occured while acessing API", e.message
    end
  end

  def test_build_daily_report
    json_data = JSON.parse(File.read('api_return.json'))
    report_sample = File.read('report_sample.dat')

    dates = @report.last_5_working_days Date.new(2019,8,9)
    daily_trade = @report.extract_information_from_json(json_data,dates)


    daily_trade_report = @report.daily_trade_report "PETR4", daily_trade

    assert_equal report_sample, daily_trade_report
  end

end
