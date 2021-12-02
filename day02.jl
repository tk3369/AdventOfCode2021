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

