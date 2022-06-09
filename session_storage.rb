# frozen_string_literal: true

require_relative 'survey'

# handles interaction with session object and user ratings/survey
class SessionStorage
  attr_reader :survey

  def initialize(session, pokedex)
    @session = session

    @session[:survey] ||= Survey.new(pokedex)
    @survey = @session[:survey]
  end

  def submitted?
    !!@session[:submitted]
  end

  def mark_submitted
    @session[:submitted] = 'true'
  end
end
