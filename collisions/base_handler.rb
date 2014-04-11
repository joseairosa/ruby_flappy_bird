module Collision
  class BaseHandler

    def initialize(window)
      @window = window
    end

    def begin(a, b, arbiter)
      @window.game_over if arbiter.first_contact?
      false
    end

    def pre_solve(a, b)

    end

    def post_solve(arbiter)
    end

    def separate
    end
  end
end