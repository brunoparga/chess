require_relative "piece"

class Chess
  # A game of chess, playable on the command line.

  def initialize
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is either a space or a Piece object.
    @board = initialize_board
    populate_board
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

  def populate_board
    # Pieces are placed on the board one file at a time.
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
    file = position.to_s[0]
    rank = position.to_s[1]
    bgcolor = (file.ord + rank.to_i) % 2 == 0 ? "\e[40m" : "\e[43m"
    if @board[position].is_a?(Piece)
      print "#{bgcolor} #{@board[position].symbol} "
    else
      print "#{bgcolor}   "
    end
  end

end
