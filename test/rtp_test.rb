# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'test_helper'
require 'rack/test'

require_relative '../rtp'

class RTPTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # TODO: add setup/teardown steps that manipulate rows in testdb (e.g. ratings)

  def survey
    last_request.session[:survey]
  end

  def test_index
    get '/'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Rate That Pokemon!'
    assert_includes last_response.body, "href='/rate'"
  end

  def test_rating
    get '/rate'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<input type="submit"'
  end

  def test_image
    get '/pokedex/001-Bulbasaur.png'
    assert_equal 200, last_response.status
  end

  def test_rate_success
    pokemon_id = '001'
    value = '1'

    post "/rate/#{pokemon_id}", { 'rating' => value }
    assert_equal 302, last_response.status

    assert_equal survey[pokemon_id], value.to_i
  end

  def test_rate_unrateable
    skip 'to be written'
    # TODO: should gracefully handle post request to a non-pokemon
  end

  def test_rate_and_submit
    skip 'to be written'
    # TODO: on final rating, should submit all ratings to db and redirect to results page

    # get "/", {}, {"rack.session" => { username: "admin"} }

    # ratings = { "Bulbasaur" => '5', "Ivysaur" => '4', "Venusaur" => '3' }
    # post '/rate', ratings

    assert_equal last_request.session[:submitted], 'true'
    assert_includes last_request.session[:message], 'Your ratings have been submitted!'
  end

  def test_flash_message
    skip 'to be implemented'
    # TODO: flash message (e.g. after submission) should display on page
  end

  def test_results
    get '/results'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'The BEST pokemon are'
  end

  def test_results_after_submission
    skip 'to be written'
    # TODO: results should have custom info based on user submitted survey
    #   ratings = { "Bulbasaur" => '5', "Ivysaur" => '4', "Venusaur" => '3' }
    #   post '/rate', ratings

    #   get '/results'

    #   assert_equal 200, last_response.status
    #   assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    #   assert_includes last_response.body, "Your top-rated pokemon are"
  end
end
