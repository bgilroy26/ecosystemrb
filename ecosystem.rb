include Enumerable

$plan = ["############################",
        "#......#....#......o......##",
        "#..........................#",
        "#..........#####...........#",
        "##.........#...#....##.....#",
        "###...........##.....#.....#",
        "#...........###......#.....#",
        "#...####...................#",
        "#...##.......o.............#",
        "#.o..#.........o.......###.#",
        "#....#.....................#",
        "############################"]

class Vector
    attr_accessor :x, :y
    def initialize(x, y)
        @x = x
        @y = y
    end

    def plus(other)
        return Vector.new(@x + other.x, @y + other.y)
    end
end

class Grid
    attr_accessor :width, :height, :space
    def initialize(width, height)
        @space = Array.new(width*height)
        @width = width
        @height = height
    end
    
    def is_inside(vector)
        return vector.x >= 0 && vector.x < @width &&
            vector.y >= 0 && vector.y < @height
    end

    def get(vector)
        return @space[vector.x + @width * vector.y]
    end
    
    def set(vector, value)
        @space[vector.x + @width * vector.y] = value
    end

    def for_each(f, context)
        (0..@height).each do |y|
            (0..@width).each do |x|
                value = @space[x+y*@width]
                if value != nil
                    f.call(context, value, Vector.new(x, y))
                end
            end
        end
    end
end

$directions = {
    "n":  Vector.new( 0, -1),
    "ne": Vector.new( 1, -1),
    "e":  Vector.new( 1,  0),
    "se": Vector.new( 1,  1),
    "s":  Vector.new( 0,  1),
    "sw": Vector.new(-1,  1),
    "w":  Vector.new(-1,  0),
    "nw": Vector.new(-1, -1)
}

class Action
    attr_accessor :type, :direction
    def initialize(type, direction)
        @type = type
        @direction = direction
    end
end

class BouncingCritter
    attr_accessor :direction
    def initialize
        @direction = $directions.keys.sample
    end

    def act(view)
        if view.look(@direction) != "."
            @direction =  view.find(".") || "s"
        end
        return Action.new("move", @direction)
    end
end

def element_from_char(legend, ch)
    if ch == "."
        return nil
    end
    element = legend[ch.to_sym].new
    element.class.module_eval { attr_accessor :origin_char }
    element.origin_char = ch
    return element
end

def char_from_element(element)
    if element == nil
        return "."
    else
        return element.origin_char
    end
end

class World
    attr_accessor :grid, :legend
    def initialize(map, legend)
        @grid = Grid.new(map[0].length, map.length)
        @legend = legend

        map.each_with_index do |line, y|
            for x in 0..line.length-1
                @grid.set(Vector.new(x, y),
                          element_from_char(@legend, line[x]))
            end
        end
    end

    def to_string
        output = ""
        for y in 0..@grid.height do
            for x in 0..@grid.width do
                element = @grid.get(Vector.new(x, y))
                output += char_from_element(element)
            end
            output += "\n"
        end
        return output
    end
    def turn
        acted = []
        @grid.for_each(lambda {
            |world, critter, vector|
            if (critter.class.method_defined? :act and !acted.include?(critter)) then
                self.class.let_act(critter, vector)
            end
        }, self)
    end
    def let_act(critter, vector)
        if critter.class == BouncingCritter
            critter.health -= 1
            if critter.health == 0
                @grid.set(Vector.new(vector.x, vector.y), Carrion)
            end
        end
        action = critter.act(View.new(self, vector))
        if action && action.type == "move"
            dest = self.check_destination(action, vector)
            if (dest && @grid.get(dest).nil?)
                @grid.set(vector, nil)
                @grid.set(dest, critter)
            end
        end
    end
end

class View
    attr_accessor :world, :vector
    def initialize(world, vector)
        @world = world
        @vector = vector
    end
end

class Wall
    def act
        return false
    end
end

class Carrion
end

world = World.new($plan, {"#": Wall, "o": BouncingCritter})

def show_frame(world)
    world.turn
    puts `clear`
    puts world.to_string
end
show_frame(world)
