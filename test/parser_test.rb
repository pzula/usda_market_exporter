require_relative './test_helper'
require 'pry'

class USDAMarketExporterTest < Minitest::Test
  def test_it_exists
    assert USDAMarketExporter::Parser
  end

  def test_it_parses_a_data_file
    mp = USDAMarketExporter::Parser.new
    markets_parsed = mp.parse_file('./test/fixtures/2013_faker_markets.csv')
    assert_equal 11, markets_parsed.count
  end

  def test_it_converts_to_boolean
    mp = USDAMarketExporter::Parser.new
    y = "Y"
    n = "N"
    assert_equal true, mp.convert_boolean(y)
    assert_equal false, mp.convert_boolean(n)
  end

  def test_it_converts_season_dates
    mp = USDAMarketExporter::Parser.new
    input_gregorian_MDY = "11/09/03 to 01/12/04"
    input_month_range = "July to October"
    assert_equal "November to January", mp.convert_season_date(input_gregorian_MDY)
    assert_equal "July to October", mp.convert_season_date(input_month_range)
  end

  def test_it_splits_each_time_to_day
    mp = USDAMarketExporter::Parser.new
    week =  "Mon:12:00 PM - 5:00 PM;Tue:12:00 PM - 5:00 PM;Wed:12:00 PM - 5:00 PM"
    assert_equal ["Mon:12:00 PM - 5:00 PM", "Tue:12:00 PM - 5:00 PM", "Wed:12:00 PM - 5:00 PM"], mp.day_splitter(week)
  end

  def test_it_finds_day_of_week_from_string
    mp = USDAMarketExporter::Parser.new
    week =  "Mon:12:00 PM - 5:00 PM;Tue:12:00 PM - 5:00 PM;Wed:12:00 PM - 5:00 PM"
    split_days = mp.day_splitter(week)
    assert_equal ["Mon", "Tue", "Wed"], split_days.map {|day_time| mp.day_of_week_finder(day_time)}
  end

  def test_it_finds_times_of_day_from_string
    mp = USDAMarketExporter::Parser.new
    week =  "Mon:12:00 PM - 5:00 PM;Tue:12:00 PM - 3:00 PM;Wed:1:00 PM - 5:00 PM"
    split_days = mp.day_splitter(week)
    assert_equal ["12:00 PM - 5:00 PM", "12:00 PM - 3:00 PM", "1:00 PM - 5:00 PM"], split_days.map {|time| mp.time_of_day_finder(time)}
  end

  def test_it_splits_start_and_end_time_and_makes_it_military
    mp = USDAMarketExporter::Parser.new
    time_of_day_found =  "12:00 PM - 5:00 PM"
    split_times = mp.start_end_time_splitter(time_of_day_found)
    assert_equal ["12:00:00", "17:00:00"], split_times.map {|time| mp.military_time_converter(time)}
  end

  def test_it_converts_times_to_hash
    mp = USDAMarketExporter::Parser.new
    week = "Mon:12:00 PM - 5:00 PM;Tue:12:00 PM - 5:00 PM;Wed:12:00 PM - 5:00 PM;Thu:12:00 PM - 5:00 PM;Fri:12:00 PM - 5:00 PM;Sat:10:00 AM - 5:00 PM;sun:12:00 PM - 5:00 PM;"
    weekend = "Sat: 8:00 AM-3:00 PM;Sun: 8:00 AM-3:00 PM;"
    parsed_week = {"Mon"=>["12:00:00", "17:00:00"], "Tue"=> ["12:00:00", "17:00:00"], "Wed"=> ["12:00:00", "17:00:00"], "Thu"=> ["12:00:00" ,"17:00:00"], "Fri"=> ["12:00:00", "17:00:00"], "Sat"=> ["10:00:00" , "17:00:00"], "Sun"=> ["12:00:00", "17:00:00"]}
    assert_equal(parsed_week, mp.convert_season_times(week))
    assert_equal({"Sat"=> ["8:00:00", "15:00:00"], "Sun"=> ["8:00:00", "15:00:00"]}, mp.convert_season_times(weekend))
  end

  def test_the_market_data_is_accessible
    mp = USDAMarketExporter::Parser.new
    markets_parsed = mp.parse_file('./test/fixtures/2013_faker_markets.csv')
    market = markets_parsed.first
    assert_equal "1005969", market.id
    assert_equal '"Y Not Wednesday Farmers Market at Town Center"', market.name
    assert_equal "http://www.sandlercenter.org/index/ynotwednesdays", market.website
    assert_equal "201 Market Street,", market.street
    assert_equal "Virginia Beach", market.city
    assert_equal "Virginia Beach", market.county
    assert_equal "Virginia", market.state
    assert_equal "23462", market.zipcode
    assert_equal "June to August", market.season_1_date
    assert_equal({"Wed"=>["17:00:00", "20:00:00"]}, market.season_1_time)
    assert_equal nil, market.season_2_date
    assert_equal nil, market.season_2_time

  end
end


