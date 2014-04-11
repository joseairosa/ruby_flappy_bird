class Floor
  FLOOR_SPEED = 3
  FLOOR_TILE_SIZE = 37

  def initialize(window)
    @window = window

    @width = Game::WIDTH+FLOOR_TILE_SIZE
    @height = 128

    @image = TexPlay::create_blank_image(@window, @width, @height)
    @texture = Gosu::Image.new(@window, 'media/ground.png')

    x = Game::WIDTH/2
    y = Game::HEIGHT-(@height/2)

    @body = CP::Body.new(INFINITY, INFINITY)
    @body.p = CP::Vec2.new(x, y)
    @image.fill 0, 0, :texture => @texture

    shape_size_x = @width/2
    shape_size_y = @height/2
    @shape_verts = [
        CP::Vec2.new(-shape_size_x, shape_size_y),
        CP::Vec2.new(shape_size_x, shape_size_y),
        CP::Vec2.new(shape_size_x, -shape_size_y),
        CP::Vec2.new(-shape_size_x, -shape_size_y),
    ]

    @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))

    @shape.e = 0
    @shape.u = 1
    @shape.group = 1
    @shape.collision_type = :floor

    @floor_texture_position = 0

    @window.space.add_static_shape(@shape)
  end

  def floor_texture_position
    unless @window.pause
      @floor_texture_position = 0 if @floor_texture_position <= -(FLOOR_TILE_SIZE-(FLOOR_TILE_SIZE%FLOOR_SPEED))
      @floor_texture_position -= FLOOR_SPEED
    end
    @floor_texture_position
  end

  def floor_height
    Game::HEIGHT-@height
  end

  def draw
    @image.draw(floor_texture_position, floor_height, 1)
  end

end