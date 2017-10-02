require_relative "piece"

class Chess
  # A game of chess, playable on the command line.

  def initialize(play)
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is either a space or a Piece object.
    @board = initialize_board
    @whites_turn = true
    welcome if play
    alternate_board if not play
  end

  def initialize_board
    # The hash is populated in this precise order so that the display_board
    # method first scans the entire file 8, then 7 and so on.
    board = Hash.new
    8.downto(1) do |rank|
      ('a'..'h').each do |file|
        square = ("#{file}#{rank.to_s}").to_sym
        empty = ' '
        board[square] = empty
      end
    end
    board
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
    # populate_board  --> This will be the correct method to call
    alternate_board     # This is just for testing
    while true    # MAYBE: later change this to 'while not checkmate'
      color = (@whites_turn ? :white : :black)
      system("clear")
      puts "It is #{color.capitalize}'s turn."   # Replace this with list of moves?
      display_board
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

  def populate_board
    # Pieces are placed on the board one file at a time.
    # This is the production version of the board.
    pieces_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    8.times do |i|
      eight = "#{(97 + i).chr}8".to_sym
      seven = "#{(97 + i).chr}7".to_sym
      two = "#{(97 + i).chr}2".to_sym
      one = "#{(97 + i).chr}1".to_sym
      @board[eight] = pieces_order[i].new(:black, eight)
      @board[seven] = Pawn.new(:black, seven)
      @board[two] = Pawn.new(:white, two)
      @board[one] = pieces_order[i].new(:white, one)
    end
  end

  def alternate_board
    # This is a simplified board, for testing purposes.
    # This method should be stored away when dev is done.
    pieces_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    8.times do |i|
      eight = "#{(97 + i).chr}8".to_sym
      one = "#{(97 + i).chr}1".to_sym
      @board[eight] = pieces_order[i].new(:black, eight)
      @board[one] = pieces_order[i].new(:white, one)
    end
    black_pawns = [:c7, :e7, :f7]
    black_pawns.each do |square|
      @board[square] = Pawn.new(:black, square)
    end
    white_pawns = [:c2, :e2, :f2]
    white_pawns.each do |square|
      @board[square] = Pawn.new(:white, square)
    end
    @board[:d5] = Knight.new(:white, :d5)
  end

  def display_board
    count = 0
    rank = 8
    print "   a  b  c  d  e  f  g  h\n"
    @board.each do |position, square|
      if count % 8 == 0
        print "#{rank} "
      end
      display_square(position)
      count += 1
      if count % 8 == 0
        print "\e[0m #{rank}\n"
        rank -= 1
      end
    end
    print "   a  b  c  d  e  f  g  h\n"
  end

  def display_square(position)
    # This uses the ASCII value of ranks ('a' == 97) to determine whether a given
    # square should be light or dark.
    file = position[0]
    rank = position[1]
    bgcolor = (file.ord + rank.to_i) % 2 == 0 ? "\e[40m" : "\e[43m"
    if @board[position].is_a?(Piece)
      print "#{bgcolor} #{@board[position].symbol} "
    else
      print "#{bgcolor}   "
    end
  end

end
