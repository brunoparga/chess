require_relative "piece"
require_relative "board"

class Chess
  # A game of chess, playable on the command line.

  def initialize(play)
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is either a space or a Piece object.
    @board = Board.new
    @whites_turn = true
    welcome if play
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
      when 'load'
        play_game # TODO
      when 'quit'
        exit
      else
        puts "I don't understand that command. Please enter 'new', 'load' or 'quit'."
      end
    end
  end

  def play_game
    system("clear")
    puts "All right, let's get started."
    # @board.populate  --> This will be the correct method to call
    @board.alternate     # This is just for testing
    while true    # MAYBE: later change this to 'while not checkmate'
      color = (@whites_turn ? :white : :black)
      system("clear")
      puts "It is #{color.capitalize}'s turn."   # Replace this with list of moves?
      @board.display
      puts "#{color.capitalize}, please make your move."
      possibilities = possible_moves(color)
      result = ""
      possibilities.each do |square, movelist|
        unless movelist.nil?
          result += "#{@board[square].to_s.capitalize} at #{square} can move to: #{movelist.join(', ')}\n"
        end
      end
      puts result
      print "Square to move from: "
      from = gets.chomp.to_sym    # add validation?
      print "Target square: "
      target = gets.chomp.to_sym
      result = move(from, target)
      puts "#{result}"
      puts "Press any key to continue."
      gets.chomp
    end
  end

  def possible_moves(color)
    moves = Hash.new([])
    @board.each do |square, piece|
      if piece.is_a?(Piece) and piece.color == color
        # Assuming each moves method will return an array of symbols of possible targets
        moves[square] = piece.moves(@board)
      end
    end
    moves
  end

  def move(from, target)
    if @board[from] == ' '
      return "There is no piece at #{from}!"
    elsif @board[from].color != (@whites_turn ? :white : :black)
      return "That is not your piece to move!"
    elsif from == target
      return "You must make a move!"
    else
      outcome = @board[from].pawn_move(@board, target)
      return outcome if outcome != true
      @whites_turn = !@whites_turn
      piece = @board[from]
      piece.position = target
      @board[target] = piece
      @board[from] = ' '
      return "Valid move."
    end
  end

end
