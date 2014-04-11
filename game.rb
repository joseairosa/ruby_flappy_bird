require 'bundler/setup'
require 'hasu'
require 'chipmunk'
require 'texplay'
require 'ashton'

Hasu.load('lib/bird.rb')
Hasu.load('lib/floor.rb')
Hasu.load('lib/pipe.rb')
Hasu.load('collisions/base_handler.rb')

INFINITY = 1.0/0

# Convenience methods for converting between Gosu degrees, radians,
# and Vec2 vectors.
#
class Numeric
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end

  def radians_to_gosu
    self * 180.0 / Math::PI + 90
  end

  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end

class Game < Hasu::Window
  WIDTH = 640
  HEIGHT = 896
  FULLSCREEN = false
  SUBSTEPS = 10
  PIPES_INTERVAL = 1500
  PIPES_SPEED = 5
  PIPES_GAP = 100
  BIRD_MAX_X = WIDTH*0.4
  SHOW_FPS = true
  FPS_POSITION = {x: WIDTH*0.05, y: HEIGHT-30}
  BUTTON_SIZE = {x: 214, y: 75}
  RESTART_BUTTON_POSITION = {x: WIDTH/2-BUTTON_SIZE[:x]/2,y: HEIGHT/2-BUTTON_SIZE[:y]/2-50}
  SHARE_BUTTON_POSITION = {x: WIDTH/2-BUTTON_SIZE[:x]/2,y: HEIGHT/2-BUTTON_SIZE[:y]/2+50}

  attr_accessor :space, :pause

  def initialize
    super(WIDTH, HEIGHT, FULLSCREEN)
    self.caption = 'Flappy The Annoying Bird'

    @background_image = Gosu::Image.new(self, 'media/background.png', true)

    Gosu::enable_undocumented_retrofication

    @dt = (1.0/60.0)

    @space = CP::Space.new
    @space.gravity = CP::Vec2.new(0, 32)

    @outline = Ashton::Shader.new fragment: :outline
    @outline.outline_width = 4.0
    @outline.outline_color = Gosu::Color::BLACK

    @font = Gosu::Font.new self, 'media/FB.ttf', 86
    @fps_font = Gosu::Font.new self, 'media/FB.ttf', 20

    @pause = false

    @points = 0

    init_menu
    set_variables
    set_collisions
  end

  def needs_cursor?; true; end

  def init_menu
    @restart_button = Gosu::Image.new(self, 'media/restart.png')
    @share_button = Gosu::Image.new(self, 'media/share.png')
  end

  def set_variables
    @floor = Floor.new(self)
    @bird = Bird.new(self)
    @last_added_pipes = @last_added_point = Gosu::milliseconds
    @show_menu = @colided = @pause = false
    @pipes = []
  end

  def set_collisions
    @space.add_collision_handler(:bird, :pipe, Collision::BaseHandler.new(self))
    @space.add_collision_handler(:bird, :floor, Collision::BaseHandler.new(self))
  end

  def add_pipes
    displacement = (100 + rand(100))
    position = [-1, 1].sample
    @pipes << Pipe.new(self, :top, displacement*position)
    puts "Adding pipe #{@pipes.last}"
    @pipes << Pipe.new(self, :bottom, displacement*position)
    puts "Adding pipe #{@pipes.last}"
    @last_added_pipes = Gosu::milliseconds
  end

  def add_point
    @points += 1
    @last_added_point = Gosu::milliseconds
    puts "Got #{@points}"
  end

  def game_over
    unless @game_over
      puts 'Game Over'
      @game_over = true
      show_menu
    end
  end

  def restart
    set_variables
  end

  def show_menu
    @show_menu = true
    @pause = true
  end

  def remove_or_validate_pipes
    @pipes.each_with_index do |pipe, i|
      if pipe.x2 <= BIRD_MAX_X && pipe.x2 >= BIRD_MAX_X-50
        add_point if Gosu::milliseconds - @last_added_point > PIPES_INTERVAL
      elsif pipe.x2 < 0
        @pipes.delete_at(i)
        @space.remove_body(pipe.body)
        puts "Removing pipe #{pipe}"
      end
    end
  end

  def pipes_speed
    if @pause
      0
    else
      PIPES_SPEED
    end
  end

  def reset

  end

  def update
    unless @pause
      add_pipes if Gosu::milliseconds - @last_added_pipes > PIPES_INTERVAL
      SUBSTEPS.times do
        remove_or_validate_pipes
        @space.step(@dt)
      end
    end
  end

  def draw
    @background_image.draw(0, 0, 0)

    @floor.draw
    @bird.draw
    @pipes.each do |pipe|
      pipe.draw(pipes_speed)
    end

    if @show_menu
      @restart_button.draw(RESTART_BUTTON_POSITION[:x], RESTART_BUTTON_POSITION[:y], 5)
      @share_button.draw(SHARE_BUTTON_POSITION[:x], SHARE_BUTTON_POSITION[:y], 5)
    end

    @font.draw @points, WIDTH/2, HEIGHT*0.1, 3, 1, 1, Gosu::Color::WHITE, shader: @outline
    if SHOW_FPS
      @fps_font.draw "FPS: #{Gosu::fps}",  FPS_POSITION[:x], FPS_POSITION[:y], 4, 1, 1, Gosu::Color::WHITE, shader: @outline
    end
  end

  def is_mouse_on_restart_button?
    mouse_x >= RESTART_BUTTON_POSITION[:x] &&
    mouse_x <= RESTART_BUTTON_POSITION[:x]+BUTTON_SIZE[:x] &&
    mouse_y >= RESTART_BUTTON_POSITION[:y] &&
    mouse_y <= RESTART_BUTTON_POSITION[:y]+BUTTON_SIZE[:y]
  end

  def button_down(button)
    case button
      when Gosu::MsLeft
        #restart if @show_menu && is_mouse_on_restart_button?
      when Gosu::KbSpace
        @bird.flap_wings!
      when Gosu::KbEscape
        close
      else
        # do nothing
    end
  end
end

Game.run
