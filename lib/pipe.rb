class Pipe

  attr_reader :body

  def initialize(window, side, displacement)
    @window = window

    @size = {x: 138, y: 793}
    @side = side

    @pipe_image = Gosu::Image.new(@window, 'media/pipe.png')

    @body = CP::Body.new(INFINITY, INFINITY)

    if side == :top
      @body.p = CP::Vec2.new(Game::WIDTH+(@size[:x]*2), 0-Game::PIPES_GAP+displacement)
      @angle = 180
    elsif :bottom
      @body.p = CP::Vec2.new(Game::WIDTH+(@size[:x]*2), @size[:y]+Game::PIPES_GAP+displacement)
      @angle = 0
    end
    puts "Created with #{@body.p.x}, #{@body.p.y}"

    shape_size_x = @size[:x]/2
    shape_size_y = @size[:y]/2

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
    @shape.collision_type = :pipe

    @window.space.add_shape(@shape)
  end

  def x1; @body.p.x - @size[:x]/2 end
  def x2; @body.p.x + @size[:x]/2 end
  def y1; @body.p.y - @size[:y]/2 end
  def y2; @body.p.y + @size[:y]/2 end

  def draw(speed)
    @body.p.x -= speed

    @pipe_image.draw_rot(@body.p.x, @body.p.y, 0, @angle)
  end

end