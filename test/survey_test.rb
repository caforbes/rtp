# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

require_relative '../survey'

HERE = File.expand_path(__dir__)
SAMPLE_POKEMON = YAML.load_file(File.join(HERE, 'pokedex.yml'))

class SurveyTest < Minitest::Test
  def setup
    @survey = Survey.new(SAMPLE_POKEMON)
    @pokemon_ids = SAMPLE_POKEMON.map { |pokemon| { number: pokemon[:number] } }
  end

  def test_rate_with_int
    @survey.rate('001', 1)
    assert_includes @survey.pokemon, { number: '001', rating: 1 }
  end

  def test_rate_with_string
    @survey.rate('001', '1')
    assert_includes @survey.pokemon, { number: '001', rating: 1 }
  end

  def test_rate_error
    assert_raises(TypeError) do
      @survey.rate('001', 'fruit')
    end
  end

  # def test_comment
  #   @survey.comment('001', 'test')
  #   assert_includes @survey.pokemon, { number: '001', comment: 'test' }
  # end

  def test_next_fresh
    assert_equal @survey.next_unrated_id, @pokemon_ids[0][:number]
  end
  
  def test_next_after_rating
    rate_one
    assert_equal @survey.next_unrated_id, @pokemon_ids[1][:number]
  end

  def test_next_after_all_rated
    rate_all
    assert_nil @survey.next_unrated_id
  end

  def test_unrated_fresh
    assert_equal @survey.unrated, @pokemon_ids
  end

  def test_unrated_after_rating
    rate_one
    @pokemon_ids.shift
    assert_equal @survey.unrated, @pokemon_ids
  end

  def test_unrated_after_all_rated
    rate_all
    assert_empty @survey.unrated
  end

  def test_complete_fresh
    assert !@survey.complete?
  end

  def test_complete_after_rating
    rate_one
    assert !@survey.complete?
  end

  def test_complete_after_all_rated
    rate_all
    assert @survey.complete?
  end

  def test_remaining_fresh
    assert_equal @survey.remaining_size, @pokemon_ids.size
  end

  def test_remaining_after_rating
    rate_one
    assert_equal @survey.remaining_size, @pokemon_ids.size - 1
  end

  def test_remaining_after_all_rated
    rate_all
    assert_equal @survey.remaining_size, 0
  end

  private

  def rate_one
    @survey.rate('001', 1)
  end

  def rate_all
    @pokemon_ids.each { |pokemon| @survey.rate(pokemon[:number], 1) }
  end
end

#   - should be stored/created by the session
#   - db storage should be able to intake whole survey object and update values
