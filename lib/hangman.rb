require 'yaml'

class Game
  attr_accessor :guesses, :word, :errors

  def initialize(params = {})
    @guesses = params.fetch(:guesses, '')
    @word = params.fetch(:word, nil)
    @errors = params.fetch(:errors, '0/8')
  end

  def to_yaml
    YAML.dump({
                guesses: @guesses,
                word: @word,
                errors: @errors
              })
  end

  def self.from_yaml(string)
    data = YAML.safe_load(string)
    new(data)
  end

  def save_game
    File.open('save.yaml', 'w') { |file| file.write(to_yaml) }
  end

  def self.load_game
    File.open('save.yaml', 'r') do |file|
      from_yaml(file)
    end
  end

  def choose_word
    File.open('google-10000-english-no-swears.txt', 'r') do |file|
      self.word = file.readlines.select { |word| word.size > 6 && word.size < 13 }.sample.chomp
    end
  end

  def make_guess
    puts 'guess: '
    gets.chomp.downcase
  end

  # this method hides the letters of a string by replacing them with underscores if they are not
  # present in the exception string
  def to_hide(string, exception)
    hidden = ''
    string.split('').each { |letter| hidden += exception.split('').include?(letter) ? letter : ' _ ' }
    hidden
  end

  def display
    puts "guesses: #{guesses} | word: #{to_hide(word, guesses)} | errors: #{errors}"
  end

  def terminate(options)
    case options
    when '!save'
      puts 'saving game ... '
      puts "game saved\n"
      save_game
    when 'win'
      puts "You win! Congratulations!\n"
      File.delete('save.yaml') if File.exist?('save.yaml')
    when 'lose'
      puts "The answer was #{word}"
      puts "You lose!\n"
      File.delete('save.yaml') if File.exist?('save.yaml')
    end
  end

  def win_or_lose
    return 'lose' if errors.to_r.to_i == 1

    'win' if to_hide(word, guesses) == word
  end

  def correct_or_incorrect(guess)
    word.include?(guess) ? 'correct' : 'incorrect'
  end

  def play
    self.word = choose_word if word.nil?
    display

    until win_or_lose
      guess =  make_guess
      if guess == '!save'
        terminate(guess)
        break
      end
      if ('a'..'z').none?(guess)
        puts 'guess a letter'
        next
      end

      self.guesses += guess
      self.errors = (errors.split('/')[0].to_i + 1).to_s + '/8' if correct_or_incorrect(guess) == 'incorrect'
      display
    end

    terminate('win') if win_or_lose == 'win'
    terminate('lose') if win_or_lose == 'lose'
  end
end

if File.exist?('save.yaml')
  puts 'Continue from saved file?(Y/n) '
  confirmation = gets.chomp
  if confirmation.downcase == 'n'
    puts 'Starting a new game ... '
    puts '** You can save the game by typing !save '
    game = Game.new
    game.play
  elsif confirmation == '' || confirmation.downcase == 'y'
    puts 'Loading the save file ... '
    game = Game.load_game
    game.play
  else
    puts 'Abort'
  end
else
  puts '** You can save the game by typing !save '
  game = Game.new
  game.play
end
