class SessionStore
  def initialize(session)
    @session = session
    @ratings = empty_ratings
  end

  private

  def new_ratings
    # connect to the db
    # load all the pokemon ids

    # @db = if Sinatra::Base.production?
    #         PG.connect(ENV['DATABASE_URL'])
    #       else
    #         PG.connect(dbname: 'rtp')
    #       end
  end
end