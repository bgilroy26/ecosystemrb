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
    @direction = $directions.keys.sample

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
end

class Wall
end

world = World.new($plan, {"#": Wall, "o": BouncingCritter})

puts world.to_string
