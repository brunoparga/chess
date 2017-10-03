require_relative "king"
require_relative "QRBN"
require_relative "pawn"
require_relative "board"
require_relative "move_checker"

class Chess
  # A game of chess, playable on the command line.

  include Move_checker    # A module that verifies moves.
  attr_accessor :board

  def initialize
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is either a space or a Piece object.
    @board = Board.new
    welcome
  end

  def welcome
    system("clear")
    puts "Hello, and welcome to Chess!"
    puts "Please enter 'new' to start a new game or 'load' to load a saved game."
    puts "You may enter 'quit' to quit."
    while true
      choice = gets.chomp.downcase
      case choice
      when 'new'
        play_game
      when 'test'
        play_game(true)
      when 'load'
        play_game # TODO saving and loading
      when 'quit'
        exit
      else
        puts "I don't understand that command. Please enter 'new', 'load' or 'quit'."
      end
    end
  end

  def play_game(test_board = false)
    system("clear")
    puts "All right, let's get started."
    @board.populate if not test_board # This will be the correct method to call
    @board.alternate if test_board    # This is just for testing
    while true    # MAYBE: later change this to 'while not checkmate'
      color = (@board.whites_turn ? :white : :black)
      system("clear")
      puts "#{color.capitalize} to move."   # Replace this with list of moves?
      puts "#{color.capitalize} is in check." if is_check?(@board, color)
      @board.display
      possible = possible_moves(@board, color)
      print_moves(@board, possible)
      from, target = prompt(possible)
      effect_move(from, target)
      @board.whites_turn = !@board.whites_turn
    end
  end

  def prompt(possible)
    # This validates the player's input by rejecting any input that's not on the
    # list of valid moves. The argument is a hash of possible_moves.
    from, target = nil
    loop do
      print "Square to move from: "
      from = gets.chomp.to_sym
      if not possible[from].empty?
        break
      else
        puts "That is not a valid start for a move."
      end
    end
    loop do
      print "Target square: "
      target = gets.chomp.to_sym
      if possible[from].include?(target)
        check = puts_in_check?(from, target, @board)
        break if not check
      end
      puts "You cannot move from #{from} to #{target}."
    end
    return from, target
  end

  def effect_move(from, target)
    # Realizes the requested move. Assumes it is valid.
    if is_castle(from, target)
      castle(from, target)
    elsif is_promotion(from, target)
      promote(from, target)
    else
      @board[from].position = target
      @board[target] = @board[from]
    end
    @board[from] = ' '
    if @board[target].is_a?(King) or @board[target].is_a?(Rook)
      @board[target].has_moved = true
    end
  end

  def is_castle(from, target)
    rank = (@board.whites_turn ? 1 : 8)
    (from == :"e#{rank}" and
    (target == :"c#{rank}" or target == :"g#{rank}") and
    @board[from].is_a?(King))
  end

  def castle(from, target)
    rank = (@board.whites_turn ? 1 : 8)
    @board[from].position = target
    @board[target] = @board[from]
    rook_start = (target == :"g#{rank}" ? :"h#{rank}" : :"a#{rank}")
    rook_end = (target == :"g#{rank}" ? :"f#{rank}" : :"d#{rank}")
    @board[rook_start].position = rook_end
    @board[rook_end] = @board[rook_start]
    @board[rook_start] = ' '
  end

  def is_promotion(from, target)
    rank = (@board.whites_turn ? 8 : 1).to_s
    @board[from].is_a?(Pawn) and target[1] == rank
  end

  def promote(from, target)
    puts "Which piece do you want to promote your pawn to?"
    print "Choose one of (Q)ueen, (R)ook, (B)ishop, k(N)ight: "
    choice = gets.chomp.upcase
    case choice
    when 'R'
      @board[target] = Rook.new((@board.whites_turn ? :white : :black), target)
      # The next line is ****EXTREMELY IMPORTANT****
      # I repeat, it is ****EXTREMELY IMPORTANT****
      # It might be the single most important line in all of the program
      # It implements the 1972 FIDE decision that a rook obtained through
      # promotion cannot castle. Thank you for saving chess, FIDE!
      @board[target].has_moved = true
    when 'B'
      @board[target] = Bishop.new((@board.whites_turn ? :white : :black), target)
    when 'K', 'N'
      @board[target] = Knight.new((@board.whites_turn ? :white : :black), target)
    else
      @board[target] = Queen.new((@board.whites_turn ? :white : :black), target)
    end
  end

end
