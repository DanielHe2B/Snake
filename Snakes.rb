=begin

  File: Snakes.rb
  Author: Daniel He
  Date: 2024-05-10
  Description: 
  
  This Ruby script creates a simple snake game using the Ruby2D library. 
  You control a snake to eat balls and earn points. 
  The game ends if the snake hits the screen boundaries or itself. 
  There are two difficulty levels (easy and hard) and tracks the player's score. 

=end



# Import the library
require 'ruby2d'

# Declare variables for screen dimensions
screen_width = 625
screen_height = 625

# Define the screen with specified dimensions, background color, and title
set width: screen_width, height: screen_height
set background: 'green'
set title: 'Snake'

# Global variable to store the highest score
$record = 0

# Define a class for the start menu
class StartMenu
  # Attribute accessor for the selected difficulty level
  attr_accessor :selected_difficulty

  # Constructor method for the start menu
  def initialize
    @selected_difficulty = nil
  end

  # Method to draw the start menu elements on the screen
  def draw
    Text.new("Select Difficulty:", x: 200, y: 200, size: 30, color: 'white', z: 4)
    Rectangle.new(x: 200, y: 250, width: 200, height: 80, color: 'red', z: 4)
    Text.new("Easy", x: 270, y: 270, size: 25, color: 'white', z: 5)
    Rectangle.new(x: 200, y: 350, width: 200, height: 80, color: 'red', z: 4)
    Text.new("Hard", x: 270, y: 370, size: 25, color: 'white', z: 5)
  end

  # Method to determine the selected difficulty level based on mouse coordinates and button coordinates
  def select_difficulty(x, y)
    if x >= 200 && x <= 400
      if y >= 250 && y <= 330
        @selected_difficulty = :easy
      elsif y >= 350 && y <= 430
        @selected_difficulty = :hard
      end
    end
  end

    # Method to reset the selected difficulty level
  def reset
    @selected_difficulty= nil
  end
end

# Define a class for the snake game
class Snake
    # Attribute writer for the direction and attribute accessor for the velocity
  attr_writer :direction
  attr_accessor :velocity

    # Constructor method for the snake
  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2, 3]]
    @direction = 'down'
    @velocity = 1
    @moving = true
    @growing=false
    @eat = Sound.new('audio/orb.mp3')
  end

    # Method to draw the snake on the screen
  def draw
    @positions.each do |position|
      tile_size = 25
      Square.new(x: position[0] * tile_size, y: position[1] * tile_size, size: tile_size - 1, color: 'red', z: 2)
    end
  end

    # Method to move the snake in the current direction
  def move
    return unless @moving
    if !@growing
    @positions.shift
    end
    case @direction
    when 'down'
      @positions.push([head[0], head[1] + 1])
    when 'up'
      @positions.push([head[0], head[1] - 1])
    when 'left'
      @positions.push([head[0] - 1, head[1]])
    when 'right'
      @positions.push([head[0] + 1, head[1]])
    end
    @growing=false
  end

    # Method to check if changing to the new direction is allowed
  def can_change_direction_to?(new_direction)
    return false unless @moving

    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
  end

    # Getter method for the x-coordinate of the snake head
  def x
    head[0]
  end

    # Getter method for the y-coordinate of the snake head
  def y
    head[1]
  end

    # Method to make the snake grow longer
  def grow
    @growing=true
    @eat.play
  end

    # Method to check if the snake has collided with itself
  def hit_itself?
    @positions.uniq.length != @positions.length
  end

    # Method to stop the snake from moving
  def stop
    @moving = false
    @velocity = 0
  end

  private # Private method for internal use within the Snake class

    # Method to retrieve the coordinates of the snake head
  def head
    @positions.last
  end
end

# Define a class for the game
class Game
    # Attribute reader for the running status of the game
  attr_reader :running

    # Constructor method for the game
  def initialize
        # Initialize game variables
    @running = true
    @score = 0
    @ball_x = rand(Window.width / 25)
    @ball_y = rand(Window.height / 25)

        # Ensure that the ball does not spawn on the snake's position
    while @ball_x == @positions or @ball_y == @positions
        @ball_x = rand(Window.width / 25)
        @ball_y = rand(Window.height / 25)
    end

        # Initialize the sound for game over
    @game_over_sound = Sound.new('audio/gta-v-wasted-death-sound.mp3')
  end

    # Method to draw game elements on the screen
  def draw
    Circle.new(x: @ball_x * 25 + 12.5, y: @ball_y * 25 + 12.5, radius: Float(25) / 2 - 1, color: 'black', z: 1)
    Text.new("Score: #{@score}", color: 'white', x: 10, y: 10, size: 25)
    if @running== false
              # Draw game over screen if the game is not running
        Rectangle.new(x: 150, y: 100, width: 300, height: 400, color: 'white', z: 4)
        Text.new("Score:#{@score}   Record:#{$record}", x:150,y:100, size: 20,color:'black', z:5)
        Text.new("Game Over", x:220, y:220, size:30, color:'black', z:7)
        Rectangle.new(x:200, y:300, width:200, height: 80,color: 'red',z:6)
        Text.new("Restart", x:250,y:320,size:30, color:'white', z:7)
        Rectangle.new(x:200, y:400, width:200, height: 80,color: 'red',z:6)
        Text.new("Close game", x:220,y:420,size:30, color:'white', z:7)
    end
    
  end

    # Method to check if the snake has hit the ball
  def snake_hit_ball?(x, y)
    @ball_x == x and @ball_y == y
  end

    # Method to update the score and reset the position of the ball
  def record_hit
    @score += 1
    if @score>=$record
      $record=@score
  end
    @ball_x = rand(Window.width / 25)
    @ball_y = rand(Window.height / 25)
  end

    # Method to end the game
  def end_game
    @running = false
    @game_over_sound.play
  end
end

# Initialize instances of classes and set default update interval
start_menu = StartMenu.new
snake = nil
game = nil
snake = Snake.new
game = Game.new

update_interval = 1.0 / 10  # Default to easy difficulty

# Event handler for mouse clicks
on :mouse do |event|
    if event.button == :left && event.type == :down
        if start_menu.selected_difficulty.nil?
                      # Select difficulty if not already selected
            start_menu.select_difficulty(event.x, event.y)
            if start_menu.selected_difficulty
              # Update update interval based on selected difficulty
              update_interval = 1.0 / (start_menu.selected_difficulty == :easy ? 10 : 30)
              snake = Snake.new
              game = Game.new
            end
      else
        if game.running == false
            # Restart game or close application based on mouse click position
            if event.x<=400 and event.x>=200 and event.y<=480 and event.y>=400 
              close
            end
            if event.x<=400 and event.x>=200 and event.y<=380 and event.y>=300 
                start_menu.reset
                snake = Snake.new
              game = Game.new
            end
          end
        end      
    end
  end

# Initialize and play background music
song=Music.new('audio/background-music.mp3')
song.loop = true
song.play

# Initialize variables for game update
last_update_time = Time.now

# Event handler for game updates
update do
        current_time = Time.now
        time_elapsed = current_time - last_update_time
      
        if time_elapsed >= update_interval
        # If it's time for an update:
          
  clear
  if start_menu.selected_difficulty.nil?# If no difficulty is selected, draw the start menu
    start_menu.draw
  
  elsif game.running# If the game is running:
    # Move snake, draw game elements, and check game conditions
    snake.move
    snake.draw
    game.draw
    

    if snake.x < 0 or snake.x >= screen_width / 25 or snake.y < 0 or snake.y >= screen_height / 25# Check if the snake hits the boundaries
      snake.stop
      game.end_game
    end

    if game.snake_hit_ball?(snake.x, snake.y)# Check if the snake eats the ball
      game.record_hit
      snake.grow
    end
    if snake.hit_itself?# Check if the snake collides with itself
        snake.stop
        game.end_game
    end
  else
        # Draw "game over" screen if game is lost
    snake.draw
    game.draw
  end
      # Update the last update time
  last_update_time = current_time
end
end

# Event handler for key presses to change snake direction
on :key_down do |event|
  if ['up', 'down', 'left', 'right'].include?(event.key)
    if snake.can_change_direction_to?(event.key)
      snake.direction = event.key
    end
  end
end

# Show the game window
show
