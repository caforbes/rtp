# frozen_string_literal: true

require 'test_helper'
require 'yaml'

require_relative '../survey'

HERE = File.expand_path(__dir__)
SAMPLE_POKEMON = YAML.load_file(File.join(HERE, 'pokedex.yml'))

class SurveyTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  def setup
    @survey = Survey.new(SAMPLE_POKEMON)
    @pokemon_ids = SAMPLE_POKEMON.map { |pokemon| pokemon[:number] }
  end

  def test_rate_accessor
    rate_one(1)
    assert_equal @survey['001'], 1
  end

  def test_rate_as_int
    rate_one('1')
    assert_equal @survey['001'], 1
  end

  def test_rate_error
    assert_raises(KeyError) do
      @survey['fruit'] = 1
    end
    assert_raises(TypeError) do
      @survey['001'] = 'fruit'
    end
  end

  def test_results
    @survey['001'] = 1
    assert_includes @survey.results, ['001', 1]
  end

  # def test_comment
  #   @survey.comment('001', 'test')
  #   assert_includes @survey.pokemon, { number: '001', comment: 'test' }
  # end

  def test_next_id
    assert_equal @survey.next_unrated_id, @pokemon_ids[0]

    rate_one
    assert_equal @survey.next_unrated_id, @pokemon_ids[1]

    rate_all
    assert_nil @survey.next_unrated_id
  end

  def test_unrated
    assert_equal @survey.unrated, @pokemon_ids

    rate_one
    @pokemon_ids.shift
    assert_equal @survey.unrated, @pokemon_ids

    rate_all
    assert_empty @survey.unrated
  end

  def test_complete
    assert !@survey.complete?

    rate_one
    assert !@survey.complete?

    rate_all
    assert @survey.complete?
  end

  def test_remaining
    assert_equal @survey.remaining_size, @pokemon_ids.size

    rate_one
    assert_equal @survey.remaining_size, @pokemon_ids.size - 1

    rate_all
    assert_equal @survey.remaining_size, 0
  end

  def test_each
    iteration_count = 0
    @survey.each do |id, values|
      if iteration_count.zero?
        assert_instance_of String, id
        assert_instance_of Hash, values
      end
      iteration_count += 1
    end
    assert_equal iteration_count, @pokemon_ids.size
  end

  def test_each_rating
    iteration_count = 0
    rate_all
    @survey.each do |_, values|
      assert_includes values.keys, :rating
      iteration_count += 1
    end
    assert_equal iteration_count, @pokemon_ids.size
  end

  def test_top_rating_none
    assert_nil @survey.top_rating_given
  end

  def test_top_rating_one
    rate_one(2)
    assert_equal @survey.top_rating_given, 2
  end

  def test_top_rating_is_lowest
    rate_all(2)
    assert_equal @survey.top_rating_given, 2
    rate_one(1)
    assert_equal @survey.top_rating_given, 1
  end

  def test_top_rated_ids_none
    assert_nil @survey.top_rated_pokemon_ids
  end

  def test_top_rated_ids_one
    rate_one
    assert_equal @survey.top_rated_pokemon_ids, [@pokemon_ids[0]]
  end

  def test_top_rated_ids_multiple
    rate_all(2)
    assert_equal @survey.top_rated_pokemon_ids, @pokemon_ids
    rate_one(1)
    assert_equal @survey.top_rated_pokemon_ids, [@pokemon_ids[0]]
  end

  private

  def rate_one(rating = 1)
    @survey['001'] = rating
  end

  def rate_all(rating = 1)
    @pokemon_ids.each { |id| @survey[id] = rating }
  end
end
