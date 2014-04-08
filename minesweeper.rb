# Andrew Chen, Frank Kotsianas
# Minesweeper.rb

# encoding: UTF-8

require 'yaml'
require 'debugger'

class Tile
  attr_accessor :has_bomb, :revealed, :flagged, :board
  attr_reader :position

  def initialize(position, brd)
    @position = position
    @board = brd

    @has_bomb = false
    @flagged = false
    @revealed = false

  end #init

  def reveal
    self.revealed = true
    self.current_state
    # self.current_state = self.underlying_state
  end #reveal

  def flag
    self.flagged = true
    self.current_state
  end

  def neighbors
    poss_diff = [-1, 0, 1].product([-1, 0, 1])
    poss_diff.delete( [0,0] )

    neighboring_positions = []
    poss_diff.each do |difference|
      neighboring_positions <<  [ position.first + difference.first,
                                  position.last  + difference.last   ]
    end #each

    neighboring_positions = neighboring_positions.select do |position|
      x,y = position
      ( x <= 8 && x >= 0 && y <= 8 && y >= 0 )
    end #select

    neighboring_positions.map do |position|
      # p position
      pos_x, pos_y = position
      brd = self.board
      grid = brd.grid[ pos_x ][ pos_y ]
    end # returns Tiles, not positions

  end #neighbors

  def neighbor_bomb_count
    # if self.has_bomb
    neighbors = self.neighbors
    sum = 0
    neighbors.each do |neighbor|
      # p self.positions
      sum += 1 if neighbor.has_bomb
    end #each
    sum
  end #neighbor_bomb_count

  def current_state
    if self.revealed == true && self.has_bomb
      return "X"
    elsif revealed == true && self.neighbor_bomb_count == 0
      return "_"
    elsif revealed == true
      self.neighbor_bomb_count == 0
    elsif self.revealed == false && flagged == false
      return "*"
    elsif self.revealed == false && flagged == true
      return "F"
    else
      return self.neighbor_bomb_count
    end #if
  end #current_state

  def show_all
    if self.has_bomb
      "B"
    elsif self.neighbor_bomb_count > 0
      self.neighbor_bomb_count
    else
      "_"
    end
  end

end #Tile

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(9) { Array.new(9, nil) }

    create_tiles
  end #init

  def display
    self.grid.each_with_index do |line, index|
      print "#{index} "
      line.each do |tile|
        print "#{tile.current_state}"
      end #each
      puts
    end #each_with_index
  end #display

  def reveal_tile(pos_x, pos_y)
    # pos_x, pos_y = *position
    curr_tile = self.grid[pos_x][pos_y]
    curr_tile.reveal
  end #reveal_tile

  def flat_tile(pos_x, pos_y)
    # pos_x, pos_y = *position
    curr_tile = self.grid[pos_x][pos_y]
    curr_tile.flag
  end #reveal_tile

  def create_tiles
    self.grid.each_with_index do |line, idx1|
      line.each_with_index do |tile, idx2|
        self.grid[idx1][idx2] = Tile.new( [idx1,idx2], self )
      end #each_with_index
    end #each_with_index

    seed_bombs
  end #create_tiles

  def seed_bombs
    total_bombs = 10
    num_bombs = 0
    until num_bombs == total_bombs
      curr_tile = self.grid.sample.sample
      unless curr_tile.has_bomb
        curr_tile.has_bomb = true
        num_bombs += 1
      end #unless
    end #until
  end #seed_bombs

end #Board

class MineSweeper
  attr_accessor :board

  def initialize
    @board = Board.new
  end #init

  def display_board
    self.board.display
  end

  def run
    # while no win
    bombs_left = 10

    10.times do
      display_board
      # have user pick a tile
      tile_str = user_pick_tile
      if tile_str.last == "F"
        pos_x, pos_y = parse_coords( tile_str[0...-1] )
        curr_tile = self.board.flag_tile( pos_x, pos_y )
      else
        pos_x, pos_y = parse_coords( tile_str[0..-1] )
        curr_tile = self.board.reveal_tile( pos_x, pos_y )
      end

      # if bomb blow up game over
      if curr_tile == "X"
        puts "YOU LOSE"
        display_board
        return false
      elsif curr_tile == "F"
        num_bombs -= 1
      end

    end
    # show win message
  end #run

  def user_pick_tile
    puts "What tile would you like to choose? (Format: x, y [,F for FLAG] )"
    tile_str = gets.chomp
  end #pick_tile

  def parse_coords( coords )
    pos_x, pos_y = coords.split(",").map(&to_i)
  end


end #Minesweeper

if __FILE__ == $PROGRAM_NAME
  p "test"
end #FILE

# letsplay = Minesweeper.new
# letsplay.run
# gameon = Board.new
# gameon.display

game = MineSweeper.new
game.run