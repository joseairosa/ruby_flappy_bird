class Bird
  SIZE = 32
  SPEED = { x: 16.0, y: 40.0 }
  JUMP_SPEED = { x: SPEED[:x], y: -65.0 }
  PREVENT_JUMP_INTERVAL = 150
  APPLY_JUMP_FORCE_INTERVAL = 125
  GOING_UP_ANGLE = -35.0

  attr_reader :shape
  attr_accessor :flapped_wings

  def initialize(window)
    @window = window
    @max_x = Game::BIRD_MAX_X
    @flapped_wings = 0
    @bird_sprite = Gosu::Image.load_tiles(@window, 'media/bird.png', 92, 64, false)

    x = 20 + SIZE/2
    y = Game::HEIGHT/2

    @body = CP::Body.new(1, 10)
    @body.p = CP::Vec2.new(x, y)
    @body.v = CP::Vec2.new(SPEED[:x], SPEED[:y])

    shape_size_x = shape_size_y = SIZE/2
    @shape_verts = [
        CP::Vec2.new(-shape_size_x, shape_size_y),
        CP::Vec2.new(shape_size_x, shape_size_y),
        CP::Vec2.new(shape_size_x, -shape_size_y),
        CP::Vec2.new(-shape_size_x, -shape_size_y),
    ]

    @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))

    @shape.e = 0
    @shape.u = 1
    @shape.collision_type = :bird

    rest_wings!

    @window.space.add_body(@body)
    @window.space.add_shape(@shape)
  end

  def can_flap_wings?
    @flapped_wings == 0 || Gosu::milliseconds - @flapped_wings > PREVENT_JUMP_INTERVAL
  end

  def can_apply_jump_force?
    @flap_wing && @flapped_wings > 0 && Gosu::milliseconds - @flapped_wings < APPLY_JUMP_FORCE_INTERVAL
  end

  def flap_wings!
    @flapped_wings = Gosu::milliseconds if can_flap_wings?
    @flap_wing = true
  end

  def rest_wings!
    @shape.body.reset_forces
    @flap_wing = false
  end

  def decide_bird_angle!
    if @body.v.y < 0
      @angle = GOING_UP_ANGLE
    else
      @angle = @body.v.to_angle.radians_to_degrees
    end

  end

  def tile_index
    if @window.pause
      1
    else
      Gosu::milliseconds / 100 % @bird_sprite.size
    end
  end

  def x1; @body.p.x - SIZE/2 end
  def x2; @body.p.x + SIZE/2 end
  def y1; @body.p.y - SIZE/2 end
  def y2; @body.p.y + SIZE/2 end

  def draw
    @body.p.x = @max_x if @body.p.x > @max_x

    if can_apply_jump_force?
      @body.v = CP::Vec2.new(JUMP_SPEED[:x], JUMP_SPEED[:y])
    else
      rest_wings!
    end

    decide_bird_angle!

    image = @bird_sprite[tile_index]
    image.draw_rot(@body.p.x, @body.p.y, 1, @angle)
  end
end
