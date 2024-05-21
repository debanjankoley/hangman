# computer chooses a random word from the dictionary
# player makes the guess
# display for incorrect and correct guesses
# game save and load functionality

require 'yaml'

class Game
  attr_accessor :guesses, :display, :word, :errors

  def initialize(params = {})
    @guesses = params.fetch(:guesses, nil)
    @display = params.fetch(:display, nil)
    @word = params.fetch(:word, nil)
    @errors = params.fetch(:errors, "0/7")
  end

  def to_yaml
    YAML.dump({
      :guesses => @guesses
      :display => @display
      :word => @word
      :errors => @errors
    })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    self.new(data)
  end

end
