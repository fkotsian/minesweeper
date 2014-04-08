# Andrew Chen, Frank Kotsianas
# Minesweeper.rb

#!/usr/bin/env ruby
#encoding: UTF-8

require 'yaml'
require 'debugger'

class Tile
  DELTAS = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]

  def initialize(board, pos)
    @board, @pos = board, pos
    @bombed, @explored, @flagged = false, false, false
  end #init

  def reveal
    if flagged
      bombed? ? 'f' : 'F'
    elsif bombed?
      explored? ? "X" : "B"
    else
      neighbors_bomb_count
    end #if
  end #reveal

  def neighbors
    neighborhood = []
    DELTAS.each do |diff|
      neighborhood  += DELTAS.map.with_index { |diff, idx| diff + pos[idx].to_i }
      neighborhood.select do |neighbor|
        neighbor[x][y] if (0 <= x) || (x <= 8) || (0 <= y) || (y <= 8)
      end #select
    end #each
  end #neighbors

  def neighbor_bomb_count
    neighbor_with_bombs = neighbors.select { |bombers| bombers.bombed }
    neighbor_with_bombs.count
  end #neighbor_bomb_count

  def seed_bomb
    @bombed = true
  end #seed_bomb

  def pin_flag
    @flagged = true
  end #pin_flag
end #Tile

class Board
  def initialize(grid_size, num_bombs)
    @grid_size, @num_bombs = grid_size, num_bombs
  end #init
end #Board

class MinesweeperGame
  LAYOUTS = {
    :small => { :grid_size => 9, :num_bombs => 10 },
    :medium => { :grid_size => 16, :num_bombs => 40 },
    :large => { :grid_size => 32, :num_bombs => 160 }
  }

  def initialize(size)
    layout = LAYOUTS[size]
    @board = Board.new(layout[:grid_size], layout[:num_bombs])
  end #init

  def play

  end #play
end #MinesweeperGame

if $PROGRAM_NAME == __FILE__

  case ARGV.count
  when 0
    MinesweeperGame.new(:small).play
  when 1
    YAML.load_file(ARGV.shift).play
  end #case
end #script