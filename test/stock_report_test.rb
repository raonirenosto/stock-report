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
end
