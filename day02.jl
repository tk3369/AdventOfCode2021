function read_data() 
    parse_line(x) = let fields = split(x, " ")
        Symbol(fields[1]), parse(Int, fields[2])
    end
    parse_line.(readlines("day02.txt"))
end

function part1(input)
    pos = 0
    depth = 0
    for (cmd, x) in input
        if cmd == :forward
            pos += x
        elseif cmd == :up
            depth -= x
        elseif cmd == :down
            depth += x
        else
            error("bad command: $cmd $x")
        end
    end
    return pos * depth 
end

function part2(input)
    pos = 0
    depth = 0
    aim = 0
    for (cmd, x) in input
        if cmd == :forward
            pos += x
            depth += aim * x
        elseif cmd == :up
            aim -= x
        elseif cmd == :down
            aim += x
        else
            error("bad command: $cmd $x")
        end
    end
    return pos * depth 
end

# Using pattern matching

using Match

function part2_match(input)
    pos = depth = aim = 0
    for (cmd, x) in input
        @match cmd begin
            :forward => (pos += x; depth += aim * x)
            :up => (aim -= x)
            :down => (aim += x)
            _ => error("bad command: $cmd $x")
        end
    end
    return pos * depth 
end

# Using custom dispatch

mutable struct State
    pos::Int
    depth::Int
    aim::Int
end

function forward!(state::State, x::Integer)
    state.pos += x
    state.depth += state.aim * x
end

up!(state::State, x::Integer) = state.aim -= x

down!(state::State, x::Integer) = state.aim += x

function read_data_md()
    methods = Dict(
        "forward" => forward!,
        "up" => up!,
        "down" => down!,
    )
    parse_line(x) = let fields = split(x, " ")
        methods[fields[1]], parse(Int, fields[2])
    end
    parse_line.(readlines("day02.txt"))
end

function part2_md(input)
    state = State(0, 0, 0)
    for cmd in input
        func = cmd[1]
        x = cmd[2]
        func(state, x)
    end
    return state.pos * state.depth
end

# Animation

function drive(input)
    pos = 0
    depth = 0
    aim = 0
    result = []
    for (cmd, x) in input
        if cmd == :forward
            pos += x
            depth += aim * x
        elseif cmd == :up
            aim -= x
        elseif cmd == :down
            aim += x
        else
            error("bad command: $cmd $x")
        end
        push!(result, (; pos, depth, aim))
    end
    return result
end

using Luxor

function make_frame(scene::Scene, frame_number::Integer, path, max_pos, max_depth, screen_width, screen_height)
    state = path[frame_number*4]
    x = state.pos * screen_width ÷ max_pos - screen_width ÷ 2
    y = state.depth * screen_height ÷ max_depth - screen_height ÷ 2
    background("black")
    sethue("red")
    circle(Point(x, y), 25, :fill)
    @info "Made circle: $x, $y"
end

function make_movie()
    screen_width = 500
    screen_height = 500
    movie = Movie(screen_width, screen_height, "day02")
    path = drive(read_data())
    max_depth = maximum(x.depth for x in path)
    max_pos = maximum(x.pos for x in path)
    frame(scene::Scene, frame_number::Integer) = make_frame(scene, frame_number, path,
        max_pos, max_depth, screen_width, screen_height)
    animate(movie, [Scene(movie, frame, 1:250)], creategif = true, pathname = "day02.gif")
end