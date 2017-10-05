module Notation

  def record_move(from, target, *args)
    # Adds one player's move to the list of moves made so far in the game. Uses
    # Standard algebraic notation.
    if @whites_turn
      @moves_so_far += "#{@move_number}. "
      @move_number += 1
    end
    if args.include?(:castle)
      @moves_so_far += "0-0"
      @moves_so_far += "-0" if target[0] == 'c'
    else
      figurine = args.include?(:figurine)
      piece = @board[from].class
      letter = case piece.to_s
      when "King" then figurine ? '♚' : 'K'
      when "Queen" then figurine ? '♛' : 'Q'
      when "Rook" then figurine ? '♜' : 'R'
      when "Bishop" then figurine ? '♝' : 'B'
      when "Knight" then figurine ? '♞' : 'K'
      else ''
      end
      capture = 'x' if @board[target].is_a?(Piece)
      @moves_so_far += "#{letter}#{capture}#{target} "
    end
  end

end
