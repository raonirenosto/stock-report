require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../stock_report.rb'

class StockReportTest < Minitest::Spec

  def test_read_config_file_not_found
    stock = StockReport.new

    begin
      stock.read_config "not_a_valid_name"
    rescue => e
      assert_equal "Could not open config.json", e.message
    end
  end

  def test_parse_fields_invalid_json
    stock = StockReport.new

    begin
      stock.parse_fields "not_a_valid_json"
    rescue => e
      assert_equal "Invalid JSON syntax on config.json", e.message
    end
  end

  def test_parse_fields_key_not_informed
    stock = StockReport.new

    begin
      stock.parse_fields '{"key": ""}'
    rescue => e
      assert_equal "API key was not informed. Set 'key' on config.json file", e.message
    end
  end

  def test_parse_fields_api_key
    stock = StockReport.new

    stock.parse_fields '{"key":"123","stocks":["PETR4"]}'

    assert_equal("123", stock.key)
  end

  def test_parse_fields_stocks
    stock = StockReport.new
    stock.parse_fields '{"key":"123","stocks":["PETR4"]}'
    assert_equal 1, stock.stocks.size
  end
end
