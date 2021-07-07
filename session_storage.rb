class SessionStorage
  def initialize(session, connection)
    @session = session
    @session[:ratings] ||= new_empty_ratings(connection)
  end

  def [](id)
    @session[:ratings][id]
  end

  def []=(id, rating_value)
    @session[:ratings][id] = rating_value
  end

  def full?
    @session[:ratings].all? { |id, value| value }
  end

  # for testing purposes
  def clear_all
    @session[:ratings] = nil
  end

  private

  def new_empty_ratings(connection)
    pokemon_list = connection.load_all_pokemon
    pokemon_list.map { |pokemon| [pokemon[:number], nil] }.to_h
  end
end