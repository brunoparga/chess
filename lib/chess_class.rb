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
    keys = possible.keys
    values = possible.values
    # 'possible' has origin squares as keys and an array of targets as values.
    # the following hash is the opposite, targets as keys and possible origins
    # as values. So it's 'elbissop' ─ 'possible' inverted.
    elbissop = Hash.new
    values.each_with_index do |array, idx|
      array.each do |tgt|
        if elbissop[tgt].nil?
          existing = []
        else
          existing = elbissop[tgt]
        end
        existing << keys[idx]
        elbissop[tgt] = existing
      end
    end
    from, target = nil
    loop do
      print "Please make your move: "
      target = gets.chomp.to_sym
      option_called(target)
      if elbissop[target].nil?
        puts "That's not a valid move."
        next
      elsif elbissop[target].length > 1
        loop do
          puts "You can move to #{target} from: #{elbissop[target].join(', ')}."
          print "Please choose one of these squares to move from: "
          from = gets.chomp.to_sym
          break if elbissop[target].include?(from)
        end
      else
        from = elbissop[target][0]
      end
      if puts_in_check?(from, target, @board)
        puts "You cannot put yourself into check."
      else
        break
      end
    end
    return from, target
  end

  def option_called(option)
    # A list of options and things to deal with them.
    # Remember that option is a symbol.
    return
  end

  def is_game_over(in_check, possible)
    # Returns true if the game is over either due to a checkmate or a stalemate.
    return false if not possible.empty?
    if in_check
      puts "Checkmate! #{@whites_turn ? "Black" : "White"} wins."
    else
      puts "Stalemate. It's a draw."
    end
    gets
    return true
  end

end
