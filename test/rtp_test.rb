ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../rtp"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Rate That Pokemon!"
    assert_includes last_response.body, "href='/rate'"
  end

  def test_rating
    get '/rate'

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Bulbasaur"
    assert_includes last_response.body, "Ivysaur"
    assert_includes last_response.body, "Venusaur"
    assert_includes last_response.body, "Charmander"
    assert_includes last_response.body, '<input type="submit"'
  end

  def test_image
    get '/pokedex/001-Bulbasaur.png'
    assert_equal 200, last_response.status
  end

  def test_rate_success
    ratings = {
      "Bulbasaur" => 5, "Ivysaur" => 4, "Venusaur" => 3, "Charmander" => 5,
    }

    post '/rate', ratings
    assert_equal 302, last_response.status
  end

  def test_rate_incomplete
    ratings = {
      "Bulbasaur" => 5
    }

    post '/rate', ratings
    assert_equal 422, last_response.status
    # decide how this should be handled / implement
  end

  def test_results_new
    get '/results'

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "The BEST pokemon are:"
  end

  # add test for user with ratings in session
end