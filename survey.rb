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

  # provides parameters pokemon_id and responses_hash
  def each(&block)
    @pokemon_questions.each(&block)
    self
  end

  def [](id)
    @pokemon_questions.fetch(id)[:rating]
  end

  def []=(id, rating_value)
    raise TypeError unless @valid_ratings.include?(rating_value.to_i)

    @pokemon_questions.fetch(id)[:rating] = rating_value.to_i
  end

  # TODO: add comment functionality; text area in survey with user comment

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

  def top_rated_pokemon_ids
    max = top_rating_given
    return unless max

    @pokemon_questions.select do |_id, info|
      info[:rating] == max
    end.keys
  end

  def top_rating_given
    # "best" rating is 1, worst is 5
    results.map { |_id, rating| rating }.compact.min
  end
end
