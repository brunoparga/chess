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
    # The board is a modified hash. Each key is the symbol of the name of the
    # square (e.g. :a1). The value is either a space or a Piece object.
    @board = Board.new
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
      color = (@board.whites_turn ? :white : :black)
      system("clear")
      puts "#{color.capitalize} to move."
      in_check = is_check?(@board, color)
      @board.display
      possible = possible_moves(@board, color)
      possible = evade_check(@board, color, possible) if in_check
      break if is_game_over(in_check, possible)
      from, target = prompt(possible)
      effect_move(from, target)
      @board.whites_turn = !@board.whites_turn
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
        # This call to puts_in_check does not seem to trigger the bug.
        puts "You cannot put yourself into check."
      else
        break
      end
    end
    return from, target
  end

  def evade_check(board, color, possible)
    puts "In evade_check. "
    movehash = possible
    # NOTE These nested enumerators are what's in common between this method and
    # #prune, from 'fubar'. The problem must be here. NOTE
    movehash.each do |from, movelist|
      @board = board
      helper = movelist.dup
      puts "Analyzing #{board[from]} at #{from}/#{board[from].position}: #{movelist.join(', ')}"
      helper.each do |target|
        hypothetical_board = Board[board]
        hypothetical_board.whites_turn = board.whites_turn
        hypothetical_board[from].position = target
        hypothetical_board[target] = hypothetical_board[from]
        hypothetical_board[from] = ' '
        if is_check?(hypothetical_board, color)
          movelist.delete(target)
          puts "Removing #{target}."
        end
        puts "Remaining move list: #{movelist.join(', ')}" if not movelist.empty?
        # This next line is a workaround to 'solve' the move bug
        @board[from].position = from
      end
      possible.delete(from) if movelist.empty?
      puts "Removed the possible from square #{from}."
    end
    puts "There are no possible moves left." if possible.empty?
    puts "Moves left: #{possible}" unless possible.empty?
    possible
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
