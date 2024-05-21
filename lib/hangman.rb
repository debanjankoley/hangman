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
      :guesses => @guesses,
      :display => @display,
      :word => @word,
      :errors => @errors
    })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    self.new(data)
  end

  def choose_word
    File.open("google-10000-english-no-swears.txt", "r") do |file|
      self.word = file.readlines.select {|word| word.size > 6 && word.size < 13}.sample.chomp
    end
  end

  def make_guess
    puts "guess: "
    gets.chomp.downcase
  end

  # this method hides the letters of a string by replacing them with underscores if they are not
  # present in the exception string
  def to_hide(string, exception)
    hidden = ""
    string.split("").each {|letter| exception.split("").include?(letter) ? hidden += letter : hidden += " _ "}
    hidden
  end

  def display
    puts "guesses: #{guesses} | word: #{to_hide(word, guesses)} | errors: #{errors}"
  end

end
