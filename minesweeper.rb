# Andrew Chen, Frank Kotsianas
# Minesweeper.rb

#!/usr/bin/env ruby
#encoding: UTF-8

require 'yaml'
require 'debugger'

class Tile
  attr_accessor :bombed, :revealed, :flagged, :board
  attr_reader :position

  def initialize(position, brd)
    @position = position
    @board = brd

    @bombed = false
    @flagged = false
    @revealed = false

  end #init

  def reveal
    self.revealed = true
    self
    # self.current_state = self.underlying_state
  end #reveal

  def flag
    self.flagged = true
    self
  end

  def unflag
    self.flagged = false
    self
  end

  def neighbors
    poss_diff = [
                   [-1, -1],
                   [-1,  0],
                   [-1,  1],
                   [0,  -1],
                   [0,   1],
                   [1,  -1],
                   [1,   0],
                   [1,   1]    ]

    neighboring_positions = []
    poss_diff.each do |difference|
      neighboring_positions <<  [ self.position.first + difference.first,
                                  self.position.last  + difference.last   ]
    end #each

    neighboring_positions = neighboring_positions.select do |pos|
      x,y = pos
      ( x <= 8 && x >= 0 && y <= 8 && y >= 0 )
    end #select

    neighbors = neighboring_positions.map do |pos|
      # p position
      pos_x, pos_y = pos
      brd = self.board
      tile = brd.grid[ pos_x ][ pos_y ]
    end # returns Tiles, not positions

  end #neighbors

  def neighbor_bomb_count
    # if self.bombed
    neighbors = self.neighbors
    sum = 0
    neighbors.each do |neighbor|
      # p self.positions
      sum += 1 if neighbor.bombed
    end #each
    sum
  end #neighbor_bomb_count

  def current_state
    if self.revealed == true && self.bombed
      return "X"
    elsif revealed == true && self.neighbor_bomb_count == 0
      return "_"
    elsif revealed == true
      self.neighbor_bomb_count
    elsif self.revealed == false && flagged == false
      return "*"
    elsif self.revealed == false && flagged == true
      return "F"
    else
      raise "State unknown to game"
    end #if
  end #current_state

  def show_all
    if self.bombed
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
    top_row = (0..self.grid.length-1).to_a.join
    puts "  #{top_row}"

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
    if curr_tile.revealed
      return curr_tile
    elsif curr_tile.flagged
      return curr_tile
    else
      curr_tile.reveal

      neighbors = curr_tile.neighbors
      reveal_neighbors( neighbors ) if ( !curr_tile.bombed && curr_tile.neighbor_bomb_count == 0 )
    end
    curr_tile
  end #reveal_tile

  def flag_tile(pos_x, pos_y)
    # pos_x, pos_y = *position
    curr_tile = self.grid[pos_x][pos_y]
    curr_tile.flag
  end #flag_tile

  def un_flag_tile(pos_x, pos_y)
    # pos_x, pos_y = *position
    curr_tile = self.grid[pos_x][pos_y]
    curr_tile.unflag
  end #un_flag_tile

  # def check_for_chain( neighbors )
  #   neighbors.each do |neighbor|
  #     if neighbor_bomb_count == 0
  #   end
  #   true
  # end

  def reveal_neighbors( neighbors )
    neighbors.each do |neighbor|
      reveal_tile( *neighbor.position )
      # neighbor.reveal
    end
  end


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
      unless curr_tile.bombed
        curr_tile.bombed = true
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
    # disp move types
    puts "COMMANDS: Use F to flag, U to unflag, E to explore, and S to save."

    # while no win
    bombs_left = 10

    until bombs_left.zero? do
      display_board
      # have user pick a tile
      tile_str = user_pick_tile

      curr_tile = handle_move( tile_str )

      # if bomb blow up game over
      if curr_tile.current_state == "X"
        puts "YOU LOSE"
        display_board
        return
      elsif curr_tile.current_state == "F" && curr_tile.bombed
        bombs_left -= 1
      elsif curr_tile.current_state == "U" && !curr_tile.bombed
        bombs_left += 1
      end
    end

    puts "You win!!! Congratulations!"
  end #run

  def handle_move( move_arr )
    move_type = move_arr[0]
    pos_x = move_arr[1].to_i
    pos_y = move_arr[2].to_i

    # if self.board.grid[ pos_x, pos_y ].revealed
    #   self.board.grid
    if move_type == "F"
      curr_tile = self.board.flag_tile( pos_x, pos_y )
    elsif move_type == "U"
      curr_tile = self.board.un_flag_tile( pos_x, pos_y )
    elsif move_type == "E"
      curr_tile = self.board.reveal_tile( pos_x, pos_y )
    elsif move_type == "S"
      saved_game = self.to_yaml
      f = File.open("minesweeper.yaml", 'w') { saved_game }
    else
      raise "Unknown command; please input E, F, U, or S before coordinates."
    end
  end


  def user_pick_tile
    puts "What tile would you like to choose? (Format: [MOVE_TYPE],x,y )"
    tile_str = gets.chomp.split(",")
  end #pick_tile

  # def parse_coords( coords )
  #   pos_x, pos_y = coords.map(&:to_i)
  # end


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