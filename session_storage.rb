class SessionStorage
  include Enumerable

  def initialize(session, connection)
    @session = session
    @session[:ratings] ||= new_empty_ratings(connection.load_all_pokemon())
  end

  def each
    @session[:ratings].each { |id, rating_info| yield(id, rating_info) }
    @session[:ratings]
  end

  # view the rating value of the pokemon at the input id
  def [](id)
    @session[:ratings][id][:rating]
  end

  # update the rating value of the pokemon at the input id
  def []=(id, rating_value)
    @session[:ratings][id][:rating] = rating_value
  end

  alias_method :rate, :[]=

  # update the comment text set for the pokemon at the input id
  def comment(id, comment_text)
    @session[:ratings][id][:comment] = comment_text
  end

  # check whether all pokemon have a rating value; return boolean
  def full?
    @session[:ratings].all? { |id, rating_data| rating_data[:rating] }
  end

  # return the id of the first pokemon with no rating value; else return nil
  def next_unrated_pokemon_id
    @session[:ratings].each do |id, rating_data|
      return id unless rating_data[:rating]
    end
    nil
  end

  # returns the lowest rating value for any pokemon in the session, or nil
  def min_rating
    @session[:ratings].values.map { |info| info[:rating] }.min
  end

  # returns the highest rating value for any pokemon in the session, or nil
  def max_rating
    @session[:ratings].values.map { |info| info[:rating] }.max
  end

  def top_rated_pokemon_ids
    max = max_rating
    @session[:ratings].select do |id, info|
      info[:rating] == max
    end.keys
  end

  private

  # create a new hash with pokemon id as key, hash of user rating data as value
  def new_empty_ratings(pokemon_list)
    pokemon_list.map do |pokemon|
      [pokemon[:number], {rating: nil, comment: nil}]
    end.to_h
  end
end