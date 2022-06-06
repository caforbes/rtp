# frozen_string_literal: true

class Survey
  def initialize(pokedex)
    @pokemon = pokedex.map { |pokemon| [pokemon[:number], {}] }.to_h
    @valid_ratings = 1..5
  end

  def ratings
    @pokemon.map { |id, info| [id, info[:rating]] }
  end

  def [](id)
    @pokemon.fetch(id)[:rating]
  end

  def []=(id, rating_value)
    raise TypeError unless @valid_ratings.include?(rating_value.to_i)

    @pokemon.fetch(id)[:rating] = rating_value.to_i
  end

  def next_unrated_id
    unrated.first
  end

  def unrated
    @pokemon.keys.reject { |id| self[id] }
  end

  def complete?
    unrated.empty?
  end

  def remaining_size
    unrated.size
  end
end
