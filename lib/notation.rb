module Notation

  def record_move(from, target, *args)
    # Adds one player's move to the list of moves made so far in the game. Uses
    # standard algebraic notation.
    if @whites_turn
      @moves_so_far += "#{@move_number}. "
      @move_number += 1
    end
    figurine = args.include?(:figurine)
    capture = 'x' if @board[target].is_a?(Piece)
    rank = from[0]
    if args.include?(:castle)
      # Notation for castling
      @moves_so_far += "0-0"
      @moves_so_far += "-0" if target[0] == 'c'
      @moves_so_far += ' '
    elsif args.include?(:promotion) and capture.nil?
      # Promotion notation must include what piece was promoted to. This is
      # simple promotion, without capture.
      letter = which_letter(target, figurine)
      @moves_so_far += "#{target}#{letter} "
    elsif args.include?(:promotion) and capture == 'x'
      # This is when the pawn captures while also being promoted.
      letter = which_letter(target, figurine)
      @moves_so_far += "#{rank}#{capture}#{target}#{letter} "
    elsif capture == 'x' and @board[from].is_a?(Pawn)
      # 1. e4 h5 2. Bd3 h4 3. g3 hxg34. Kf3 g6 5. 0-0g2 6. Ba6 f1xB
      # Pawn capture is notated by pawn rank
      @moves_so_far += "#{rank}#{capture}#{target} "
    else
      # The standard notation
      letter = which_letter(from, figurine)
      @moves_so_far += "#{letter}#{capture}#{target} "
    end
  end

  def which_letter(where, figurine)
    piece = @board[where].class
    case piece.to_s
    when "King" then figurine ? '♚' : 'K'
    when "Queen" then figurine ? '♛' : 'Q'
    when "Rook" then figurine ? '♜' : 'R'
    when "Bishop" then figurine ? '♝' : 'B'
    when "Knight" then figurine ? '♞' : 'N'
    else ''
    end
  end

end
