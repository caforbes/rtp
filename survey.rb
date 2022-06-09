# frozen_string_literal: true

# Stores pokedex ids and user responses/ratings
class Survey
  include Enumerable

  def initialize(pokedex)
    @pokemon_questions = pokedex.map { |pokemon| [pokemon[:number], {}] }.to_h
    @valid_ratings = 1..5
  end

  def results
    @pokemon_questions.map { |id, info| [id, info[:rating]] }
  end

  # TODO: test me
  def each(&block)
    @pokemon_questions.each(&block)
    @pokemon_questions
  end

  def [](id)
    @pokemon_questions.fetch(id)[:rating]
  end

  def []=(id, rating_value)
    raise TypeError unless @valid_ratings.include?(rating_value.to_i)

    @pokemon_questions.fetch(id)[:rating] = rating_value.to_i
  end

  # def comment(id, comment_text)
  #   # TODO: write tests, incorporate into functionality
  #   @pokemon_questions.fetch(id)[:comment] = comment_text
  # end

  def next_unrated_id
    unrated.first
  end

  def unrated
    @pokemon_questions.keys.reject { |id| self[id] }
  end

  def complete?
    unrated.empty?
  end

  def remaining_size
    unrated.size
  end

  # TODO: write tests
  def top_rated_pokemon_ids
    max = top_rating_given
    @pokemon_questions.select do |_id, info|
      info[:rating] == max
    end.keys
  end

  private

  # TODO: write tests
  # returns the highest rating value for any pokemon in the session, or nil
  def top_rating_given
    # highest/"best" value is 1
    @pokemon_questions.values.filter_map.min
  end
end
