require_relative "piece"

class Chess
  # A game of chess, playable on the command line.

  def initialize
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is a Square object.
    @board = initialize_board
    populate_board
  end

  def initialize_board
    # The hash is populated in this precise order so that the display_board
    # method first scans the entire file 8, then 7 and so on.
    board = Hash.new
    8.downto(1) do |rank|
      ('a'..'h').each do |file|
        name = ("#{file}#{rank.to_s}").to_sym
        square = Square.new(file, rank)
        board[name] = square
      end
    end
    board
  end

  def populate_board
    pieces_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    8.times do |i|
      eight = "#{(97 + i).chr}8".to_sym
      seven = "#{(97 + i).chr}7".to_sym
      two = "#{(97 + i).chr}2".to_sym
      one = "#{(97 + i).chr}1".to_sym
      @board[eight].piece = pieces_order[i].new(:black)
      @board[seven].piece = Pawn.new(:black)
      @board[two].piece = Pawn.new(:white)
      @board[one].piece = pieces_order[i].new(:white)
    end
  end

  def display_board
    count = 0
    file = 8
    print "   a  b  c  d  e  f  g  h\n"
    @board.each do |position, square|
      if count % 8 == 0
        print "#{file} "
      end
      display_square(square)
      count += 1
      if count % 8 == 0
        print "\e[0m #{file}\n"
        file -= 1
      end
    end
    print "   a  b  c  d  e  f  g  h\n"
  end

  def display_square(square)
    # This uses the ASCII value of ranks ('a' == 97) to determine whether a given
    # square should be light or dark.
    color = (square.file.ord + square.rank) % 2 == 0 ? "\e[40m" : "\e[43m"
    if square.piece.is_a?(Piece)
      print "#{color} #{square.piece.symbol} "
    else
      print "#{color}   "
    end
  end

end

class Square
  # A square on the chessboard. It has instance variables for its position on
  # the board (from a1 to h8) and for the piece currently occupying it.

  attr_reader :file, :rank, :position
  attr_accessor :piece

  def initialize(file, rank)
    @file = file
    @rank = rank
    @position = ("#{file}#{rank.to_s}").to_sym
    @piece = ' '
  end

end
