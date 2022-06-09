# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

require_relative '../survey'

HERE = File.expand_path(__dir__)
SAMPLE_POKEMON = YAML.load_file(File.join(HERE, 'pokedex.yml'))

class SurveyTest < Minitest::Test
  def setup
    @survey = Survey.new(SAMPLE_POKEMON)
    @pokemon_ids = SAMPLE_POKEMON.map { |pokemon| pokemon[:number] }
  end

  def test_rate_as_int
    @survey['001'] = 1
    assert_equal @survey['001'], 1

    @survey['002'] = '1'
    assert_equal @survey['002'], 1
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

  private

  def rate_one
    @survey['001'] = 1
  end

  def rate_all
    @pokemon_ids.each { |id| @survey[id] = 1 }
  end
end
