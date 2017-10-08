module Move_maker

  def effect_move(from, target, disambiguation)
    # Realizes the requested move. Assumes it is valid.
    @board.en_passant = nil unless @board[from].is_a?(Pawn)
    allows_en_passant(from, target)
    if is_castle(from, target)
      record_move(from, target, :castle)
      castle(from, target)
    elsif is_promotion(from, target)
      promote(from, target)
      record_move(from, target, :promotion)
    elsif is_en_passant(from, target)
      en_passant(from, target)
      record_move(from, target, :en_passant)
    else
      record_move(from, target, disambiguation)
      @board[from].position = target
      @board[target] = @board[from]
    end
    @board[from] = ' '
    if @board[target].is_a?(King) or @board[target].is_a?(Rook)
      @board[target].has_moved = true
    end
  end

  def allows_en_passant(from, target)
    # This method sets the en_passant flag to its correct state.
    # First, every move sets the flag to nil.
    # If the moving piece is a pawn...
    return unless @board[from].is_a?(Pawn)
    # ...let's see if it's advancing two squares.
    if (from[1].to_i == (@whites_turn ? 2 : 7)) and (target[1].to_i == (@whites_turn ? 4 : 5))
      # If e.p. is allowed, this variable contains the square where en passant
      # would happen.
      @board.en_passant = :"#{target[0]}#{(@whites_turn ? 3 : 6)}"
    end
  end

  def is_en_passant(from, target)
    # Checks if a move is an en passant capture.
    # The target for en passant must not be nil...
    ((not @board.en_passant.nil?) and
    # ...the moving piece must be a pawn...
    (@board[from].is_a?(Pawn)) and
    # ...and it must actually be moving there.
    target == @board.en_passant)
  end

  def en_passant(from, target)
    # These lines take care of the capturing pawn
    @board[from].position = target
    @board[target] = @board[from]
    # Since target is where the capturing pawn is from, we must determine
    # where the captured pawn is and remove it.
    rank = (@whites_turn ? 5 : 4)
    @board[:"#{target[0]}#{rank}"].position = nil
    @board[:"#{target[0]}#{rank}"] = ' '
    # This is the wrong place for this, but...
    @board.en_passant = nil
  end

  def is_castle(from, target)
    rank = (@whites_turn ? 1 : 8)
    (from == :"e#{rank}" and
    (target == :"c#{rank}" or target == :"g#{rank}") and
    @board[from].is_a?(King))
  end

  def castle(from, target)
    rank = (@whites_turn ? 1 : 8)
    @board[from].position = target
    @board[target] = @board[from]
    rook_start = (target == :"g#{rank}" ? :"h#{rank}" : :"a#{rank}")
    rook_end = (target == :"g#{rank}" ? :"f#{rank}" : :"d#{rank}")
    @board[rook_start].position = rook_end
    @board[rook_end] = @board[rook_start]
    @board[rook_start] = ' '
  end

  def is_promotion(from, target)
    rank = (@whites_turn ? 8 : 1).to_s
    @board[from].is_a?(Pawn) and target[1] == rank
  end

  def promote(from, target)
    puts "Which piece do you want to promote your pawn to?"
    print "Choose one of (Q)ueen, (R)ook, (B)ishop, k(N)ight: "
    choice = gets.chomp.upcase
    case choice
    when 'R'
      @board[target] = Rook.new((@whites_turn ? :white : :black), target)
      # The next line is ****EXTREMELY IMPORTANT****
      # I  repeat, it is ****EXTREMELY IMPORTANT****
      # It might be the single most important line in all of the program
      # It implements the 1972 FIDE decision that a rook obtained through
      # promotion cannot castle. Thank you, FIDE, for saving chess!
      @board[target].has_moved = true
    when 'B'
      @board[target] = Bishop.new((@whites_turn ? :white : :black), target)
    when 'K', 'N'
      @board[target] = Knight.new((@whites_turn ? :white : :black), target)
    else
      @board[target] = Queen.new((@whites_turn ? :white : :black), target)
    end
  end

end
