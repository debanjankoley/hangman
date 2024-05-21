require 'yaml'

class Game
  attr_accessor :guesses, :word, :errors

  def initialize(params = {})
    @guesses = params.fetch(:guesses, nil)
    @word = params.fetch(:word, nil)
    @errors = params.fetch(:errors, "0/8")
  end

  def to_yaml
    YAML.dump({
      :guesses => @guesses,
      :word => @word,
      :errors => @errors
    })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    self.new(data)
  end

  def save_game
    File.open("save.yaml", "w") { |file| file.write(self.to_yaml) }
  end

  def self.load_game
    File.open("save.yaml", "r") do |file|
      self.from_yaml(file)
    end
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

  def terminate(options)
    case options
    when "!save"
      puts "saving game ... "
      puts "game saved\n"
      self.save_game
    when "win"
      puts "You win! Congratulations!\n"
      File.delete("save.yaml") if File.exist?("save.yaml")
    when "lose"
      puts "The answer was #{word}"
      puts "You lose!\n"
      File.delete("save.yaml") if File.exist?("save.yaml")
    end
  end

  def win_or_lose
    return "lose" if errors.to_i == 1
    return "win" if to_hide(word, guesses) == word
    false
  end

  def correct_or_incorrect(guess)
    word.include?(guess) ? "correct" : "incorrect"
  end

  def new_game

  end

end
