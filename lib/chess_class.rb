require_relative "king"
require_relative "QRBN"
require_relative "pawn"
require_relative "board"
require_relative "move_checker"
require_relative "move_maker"
require_relative "notation"

class Chess
  # A game of chess, playable on the command line.

  include Move_checker    # A module that verifies moves.
  include Move_maker      # A module that effects the moves.
  include Notation
  attr_accessor :board, :whites_turn
  attr_writer :moves_so_far, :move_number

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
        start_game
        play_game
      when 'load'
        load_game
        play_game
      when 'quit'
        break
      else
        puts "I don't understand that command. Please enter 'new', 'load' or 'quit'."
      end
    end
  end

  def start_game
    # Just basic tasks that are necessary at the beginning of the game.
    # Loaded games build on this.
    @board.populate
    @move_number = 1
    @moves_so_far = ""
    @whites_turn = true
  end

  def load_game
    load_game = File.read("saved_game.txt")
    past_moves = load_game.scan(/(?:\d+\. )?([KQRBN]?x?[a-h1-8]?x?[a-h][1-8]|O-O-O|O-O)[\+\?!#(?:e.p.)]*/)
    start_game
    loop do
      color = (@whites_turn ? :white : :black)
      system("clear")
      possible = possible_moves(@board, color)
      from, target, disambiguation = read_move(possible, past_moves)
      break if from == :done
      effect_move(from, target, disambiguation)
      @board.display
      @whites_turn = !@whites_turn
      gets
    end
  end

  def read_move(possible, moves)
    # This should return the same thing as the prompt method, but reading from
    # the saved game.
    from, target, disambiguation = nil
    move = moves.shift
    return :done if move.nil?
    move = move[0]
    move.delete("x")
    if move[0] == 'O' or move[0] == '0'
      rank = (@whites_turn ? '1' : '8')
      from = :"e#{rank}"
      target = (move.length > 3 ? :"c#{rank}" : :"g#{rank}")
    else
      target = move.slice(-2..-1).to_sym
      elbissop = revert(possible)
      if elbissop[target].length == 1
        from = elbissop[target][0]
      else
        move_list = elbissop[target]
        pieces = can_reach(move_list)
        piece_moved = case move[0]
        when 'K' then 'King'
        when 'Q' then 'Queen'
        when 'R' then 'Rook'
        when 'B' then 'Bishop'
        when 'N' then 'Knight'
        else 'Pawn'
        end
        if pieces[piece_moved].length == 1
          from = pieces[piece_moved][0]
        else
          disambiguation = move[-3]
          pieces[piece_moved].each do |square|
            from = square if disambiguation == square[0] or disambiguation == square[1]
          end
        end
      end
    end
    return from, target, disambiguation
  end

  def play_game
    loop do
      color = (@whites_turn ? :white : :black)
      system("clear")
      puts "#{color.capitalize} to move."
      @board.display
      possible = possible_moves(@board, color)
      in_check = is_check?(@board, color)
      if in_check
        @moves_so_far[-1] = "+ "
        possible = evade_check(@board, color, possible)
      end
      break if is_game_over(in_check, possible)
      puts @moves_so_far
      from, target, disambiguation = prompt(possible)
      break if from == :resign or from == :draw
      effect_move(from, target, disambiguation)
      @whites_turn = !@whites_turn
    end
  end

  def prompt(possible)
    # Gets move input and validates it. Argument is a hash of possible_moves.
    # Returns a square to move from, a square to move to, and, if necessary, a
    # disambiguating string for notation.

    # This hash is in a sense the reverse of the 'possible' hash, so its name
    # 'possible' backwards.
    elbissop = revert(possible)
    from, target, disambiguation = nil
    loop do
      print "Please make your move: "
      target = gets.chomp.to_sym
      option = option_called(target)
      return option if option == :resign or option == :draw
      if elbissop[target].nil?
        puts "That is not a valid move."
        next
      elsif elbissop[target].length > 1
        # If there is more than one square that can reach the target, it is
        # necessary to see if there's more than one piece of the same type
        move_list = elbissop[target]
        pieces = can_reach(move_list)
        loop do
          puts "You can move to #{target} from: #{elbissop[target].join(', ')}."
          print "Please choose where to move from: "
          from = gets.chomp.to_sym
          disambiguation = disambiguate(from, pieces)
          break if elbissop[target].include?(from)
        end
      else
        from = elbissop[target][0]
      end
      if puts_in_check?(from, target, @board)
        puts "That is not a valid move."
      else
        break
      end
    end
    return from, target, disambiguation
  end

  def option_called(option)
    # A list of options and things to deal with them.
    # Remember that option is a symbol.
    return if option.nil? or is_square?(option)
    player = (@whites_turn ? :White : :Black)
    opponent = (@whites_turn ? :Black : :White)
    case option
    when :resign
      puts "Are you sure? [y/N]"
      choice = gets.chomp.upcase
      return unless choice == 'Y'
      puts "#{player} resigned. #{opponent} wins. Game over."
      gets
      return option
    when :draw, :"offer draw"
      puts "#{player} is offering a draw."
      puts "#{opponent}, do you accept? [y/N]"
      choice = gets.chomp.upcase
      @moves_so_far += "(=)"
      if choice != 'Y'
        puts "#{opponent} rejected the draw offered by #{player}."
        gets
      else
        @moves_so_far += "½–½"
        puts "#{opponent} accepted the draw offered by #{player}. Game over."
        gets
        return :draw
      end
    when :save
      savefile = File.new("saved_game.txt", "w")
      savefile.puts @moves_so_far
      savefile.close
      puts "Game saved."
    else
      puts "I don't recognize that option."
    end
  end

  def is_game_over(in_check, possible)
    # Returns true if the game is over either due to a checkmate or a stalemate.
    return false if not possible.empty?
    if in_check
      winner = (@whites_turn ? "Black" : "White")
      @moves_so_far[-1] = "\# #{winner == "White" ? "1-0" : "0-1" }"
      puts "#{@moves_so_far}\nCheckmate! #{winner} wins. Game over."
    else
      @moves_so_far += "½–½"
      puts "#{@moves_so_far}\nStalemate. It's a draw. Game over."
    end
    gets
    return true
  end

end
