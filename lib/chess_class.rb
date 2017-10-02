require_relative "piece"
require_relative "board"

class Chess
  # A game of chess, playable on the command line.

  def initialize
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is either a space or a Piece object.
    @board = Board.new
    @whites_turn = true
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

  def play_game(testing = false)
    system("clear")
    puts "All right, let's get started."
    @board.populate if not testing # This will be the correct method to call
    @board.alternate if testing    # This is just for testing
    while true    # MAYBE: later change this to 'while not checkmate'
      color = (@whites_turn ? :white : :black)
      system("clear")
      puts "#{color.capitalize} to move."   # Replace this with list of moves?
      @board.display
      possible = possible_moves(color)
      print_moves(possible)
      from, target = prompt(possible)
      effect_move(from, target)
      @whites_turn = !@whites_turn
    end
  end

  def possible_moves(color)
    # This outputs a hash where the keys are squares and the values are arrays
    # of squares reachable from the key.
    moves = Hash.new([])
    @board.each do |square, piece|
      if piece.is_a?(Piece) and piece.color == color
        # Assuming each moves method will return an array of symbols of possible targets
        moves[square] = piece.moves(@board)
      end
    end
    moves
  end

  def print_moves(possible)
    # This takes in a possible_moves hash and prints it out.
    result = ""
    possible.each do |square, movelist|
      unless movelist.empty?
        result += "#{@board[square].to_s.capitalize} at #{square} can move to: #{movelist.join(', ')}\n"
      end
    end
    puts result
  end

  def prompt(possible)
    # For the time being, this assumes the player enter valid, existing squares.
    # The argument is a hash of possible_moves.
    from, target = nil
    loop do
      print "Square to move from: "
      from = gets.chomp.to_sym
      if not possible[from].empty?
        break
      else
        puts "That is not a valid start for a move."
      end
    end    # add more validation?
    loop do
      print "Target square: "
      target = gets.chomp.to_sym
      if possible[from].include?(target)
        break
      else
        puts "You cannot move to #{target} from #{from}."
      end
    end
    return from, target
  end

  def effect_move(from, target)
    # Realizes the requested move. Assumes it is valid.
    @board[from].position = target
    @board[target] = @board[from]
    if @board[target].is_a?(King) or @board[target].is_a?(Rook)
      @board[target].has_moved = true
    end
    @board[from] = ' '
  end

end
