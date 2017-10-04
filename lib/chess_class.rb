require_relative "king"
require_relative "QRBN"
require_relative "pawn"
require_relative "board"
require_relative "move_checker"
require_relative "move_maker"

class Chess
  # A game of chess, playable on the command line.

  include Move_checker    # A module that verifies moves.
  include Move_maker      # A module that effects the moves.
  attr_accessor :board, :whites_turn

  def initialize
    # The board is a modified hash. Each key is the symbol of the name of the
    # square (e.g. :a1). The value is either a space or a Piece object.
    @board = Board.new
    @whites_turn = true
    welcome
  end

  def welcome
    # Maybe this should be in ../chess.rb
    loop do
      system("clear")
      puts "Hello, and welcome to Chess!"
      puts "Please enter 'new' to start a new game or 'load' to load a saved game."
      puts "You may enter 'quit' to quit."
      choice = gets.chomp.downcase
      case choice
      when 'new'
        play_game
      when 'load'
        play_game # TODO saving and loading
      when 'quit'
        break
      else
        puts "I don't understand that command. Please enter 'new', 'load' or 'quit'."
      end
    end
  end

  def play_game
    @board.populate
    loop do
      color = (@whites_turn ? :white : :black)
      system("clear")
      puts "#{color.capitalize} to move."
      @board.display
      possible = possible_moves(@board, color)
      in_check = is_check?(@board, color)
      possible = evade_check(@board, color, possible) if in_check
      break if is_game_over(in_check, possible)
      from, target = prompt(possible)
      effect_move(from, target)
      @whites_turn = !@whites_turn
      gets
    end
  end

  def prompt(possible)
    # Gets move input and validates it. Argument is a hash of possible_moves.
    from, target = nil
    loop do
      print "Square to move from: "
      from = gets.chomp.to_sym
      print "Target square: "
      target = gets.chomp.to_sym
      if possible[from].empty?
        puts "That is not a valid start for a move."
      elsif not possible[from].include?(target)
        puts "You cannot move from #{from} to #{target}."
      elsif puts_in_check?(from, target, @board)
        puts "You cannot put yourself into check."
      else
        break
      end
    end
    return from, target
  end

  def is_game_over(in_check, possible)
    # Returns true if the game is over either due to a checkmate or a stalemate.
    return false if not possible.empty?
    if in_check
      puts "Checkmate! #{@whites_turn == true ? "Black" : "White"} wins."
    else
      puts "Stalemate. It's a draw."
    end
    gets
    return true
  end

end
