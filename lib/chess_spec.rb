require 'chess'

describe Chess do
  let(:game) { Chess.new }

  describe "#initialize" do
    context "when initializing the board" do
      it "creates a 64-element hash" do
        expect(game.board.length).to eq(64)
      end

      it "has symbols as keys and Squares as values" do
        expect(game.board[:a1]).to be_an_instance_of(Square)
      end

    end
  end

  describe "#initialize_board" do
    it "is a Hash" do
      board = game.initialize_board
      expect(board).to be_a(Hash)
    end
  end
end

describe Square do

  describe "#initialize" do

    context "when initializing a Square" do
      let(:a_seven) { Square.new('a', 7) }

      it "is a Square" do
        expect(a_seven).to be_a(Square)
      end

      it "has the given rank" do
        expect(a_seven.rank).to eq(7)
      end

      it "has the given file" do
        expect(a_seven.file).to eq('a')
      end

      it "has the correct position" do
        expect(a_seven.position).to eq(:a7)
      end
    end

  end
end

describe Piece do

  describe "#initialize" do
    let(:piece) { Piece.new(:white) }

    it "is a Piece" do
      expect(piece).to be_an_instance_of(Piece)
    end

    it "is white" do
      expect(piece.color).to eq(:white)
    end
  end
end

describe King do
  describe "#initialize" do
    let(:king) { King.new(:black) }

    it "is a Piece" do
      expect(king).to be_a(Piece)
    end

    it "is a King" do
      expect(king).to be_an_instance_of(King)
    end

    it "is black" do
      expect(king.color).to eq(:black)
    end

    it "has a symbol of ♚" do
      expect(king.symbol).to eq('♚')
    end
  end
end

describe Queen do
  describe "#initialize" do
    let(:queen) { Queen.new(:white) }

    it "is a Piece" do
      expect(queen).to be_a(Piece)
    end

    it "is a Queen" do
      expect(queen).to be_an_instance_of(Queen)
    end

    it "is white" do
      expect(queen.color).to eq(:white)
    end

    it "has a symbol of ♕" do
      expect(queen.symbol).to eq('♕')
    end
  end
end

describe Rook do
  describe "#initialize" do
    let(:rook) { Rook.new(:black) }

    it "is a Piece" do
      expect(rook).to be_a(Piece)
    end

    it "is a Rook" do
      expect(rook).to be_an_instance_of(Rook)
    end

    it "is black" do
      expect(rook.color).to eq(:black)
    end

    it "has a symbol of ♜" do
      expect(rook.symbol).to eq('♜')
    end
  end
end

describe Bishop do
  describe "#initialize" do
    let(:bishop) { Bishop.new(:white) }

    it "is a Piece" do
      expect(bishop).to be_a(Piece)
    end

    it "is a Bishop" do
      expect(bishop).to be_an_instance_of(Bishop)
    end

    it "is white" do
      expect(bishop.color).to eq(:white)
    end

    it "has a symbol of ♗" do
      expect(bishop.symbol).to eq('♗')
    end
  end
end

describe Knight do
  describe "#initialize" do
    let(:knight) { Knight.new(:black) }

    it "is a Piece" do
      expect(knight).to be_a(Piece)
    end

    it "is a Knight" do
      expect(knight).to be_an_instance_of(Knight)
    end

    it "is black" do
      expect(knight.color).to eq(:black)
    end

    it "has a symbol of ♞" do
      expect(knight.symbol).to eq('♞')
    end
  end
end

describe Pawn do
  describe "#initialize" do
    let(:pawn) { Pawn.new(:white) }

    it "is a Piece" do
      expect(pawn).to be_a(Piece)
    end

    it "is a Pawn" do
      expect(pawn).to be_an_instance_of(Pawn)
    end

    it "is white" do
      expect(pawn.color).to eq(:white)
    end

    it "has a symbol of ♙" do
      expect(pawn.symbol).to eq('♙')
    end
  end
end
