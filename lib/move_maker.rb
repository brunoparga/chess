module Move_maker

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
