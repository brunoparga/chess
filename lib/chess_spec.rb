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
