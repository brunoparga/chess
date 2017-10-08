module Notation

  def record_move(from, target, *args)
    # Adds one player's move to the list of moves made so far in the game. Uses
    # standard algebraic notation by default.
    if @whites_turn
      @moves_so_far += "#{@move_number}. "
      @move_number += 1
    end
    # It is possible to pass the :figurine argument to this method, which causes
    # notation to switch to figurine algebraic notation.
    figurine = args.include?(:figurine)
    # The notation for each move begins by representing which piece is being
    # moved. If the move is a promotion, the letter represents the new piece.
    letter = which_letter(from, figurine)
    letter = which_letter(target, figurine) if args.include?(:promotion)
    # Notation includes an 'x' before the target square if there is a captured
    # piece there.
    capture = 'x' if @board[target].is_a?(Piece) or args.include?(:en_passant)
    # When more than one pawn can capture the same piece, they are disambiguated
    # by file.
    file = from[0]
    # This method can be passed a short string to be included in notation, for
    # move disambiguation purposes. If that is the case, the 'strings' array
    # will not be empty and be caught below.
    strings = args.select { |arg| arg.is_a?(String) }
    if args.include?(:castle)
      # Notation for castling
      @moves_so_far += "O-O"
      @moves_so_far += "-O" if target[0] == 'c'
      @moves_so_far += ' '
    elsif args.include?(:promotion) and capture.nil?
      # Promotion notation must include what piece was promoted to. This is
      # simple promotion, without capture.
      @moves_so_far += "#{target}#{letter} "
    elsif args.include?(:promotion) and capture == 'x'
      # This is when the pawn captures while also being promoted.
      @moves_so_far += "#{file}#{capture}#{target}#{letter} "
    elsif capture == 'x' and @board[from].is_a?(Pawn)
      # Pawn capture is notated by pawn file
      @moves_so_far += "#{file}#{capture}#{target} "
      @moves_so_far[-1] = "e.p. " if args.include?(:en_passant)
    elsif not strings.empty?
      # Ambiguous moves are disambiguated first by file, then by rank, and even
      # by both file and rank, if there are three (!) pieces of the same type.
      disambiguation = strings[0]
      @moves_so_far += "#{letter}#{disambiguation}#{capture}#{target} "
    else
      # The standard notation
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

  def is_square?(thing)
    # Returns true if thing is a two-character symbol whose first character is
    # between a and h and whose second character is between 1 and 8 (i.e. it is
    # a square on the board)
    return false if thing.length != 2 or (not thing.is_a?(Symbol))
    return (thing[0].between?('a', 'h') and thing[1].to_i.between?(1, 8))
  end

  def revert(possible)
    # Reverts a list of possible moves, such that each key is a target square
    # and its value is the squares that can reach it.

    # First off, separate the possible moves hash into its constituents to
    # prevent the move bug.
    keys = possible.keys
    values = possible.values

    reversed = Hash.new
    values.each_with_index do |array, idx|
      array.each do |tgt|
        if reversed[tgt].nil?
          existing = []
        else
          existing = reversed[tgt]
        end
        existing << keys[idx]
        reversed[tgt] = existing
      end
    end
    reversed
  end

  def can_reach(move_list)
    # Takes in a list of squares that can reach some square and returns a hash.
    # The keys are piece types. The values are arrays containing the squares
    # occupied by the pieces of that type that can reach the initially given square.
    piece_list = move_list.map { |sq| @board[sq].to_s }
    piece_count = piece_list.map { |piece| piece_list.count(piece) }
    pieces = Hash.new
    piece_count.each_with_index do |count, index|
      pieces[piece_list[index]] = [] if pieces[piece_list[index]].nil?
      pieces[piece_list[index]] << move_list[index]
    end
    pieces
  end

  def disambiguate(from, pieces)
    # Returns a string that is used in notation to disambiguate a move.
    chosen_piece = @board[from].to_s
    if pieces.keys.include?(chosen_piece) and pieces[chosen_piece].length > 1
      choices = pieces[chosen_piece]
      choices.delete(from)
      file = choices.any? { |sq| from[0] == sq[0] }
      rank = choices.any? { |sq| from[1] == sq[1] }
      if not file
        return from[0]
      elsif not rank
        return from[1]
      else
        return from.to_s
      end
    end
  end

end
