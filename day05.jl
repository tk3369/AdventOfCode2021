using OffsetArrays

"""
Read data and return array of lines. Each line is in this format.
[(x = 645, y = 570), (x = 517, y = 570)]
"""
function read_data(filename)
    lines = readlines(filename)
    return map.(parse_coordinates, split.(lines, " -> "))
end

"Return a named tuple given a string of `x,y`"
function parse_coordinates(coord)
    v = parse.(Int, split(coord, ","))
    return (x = v[1], y = v[2])
end

"Returns true if the line is either horizontal or vertical"
function is_hv(line)
    a, b = line
    return a.x == b.x || a.y == b.y
end

"Returns true if the line is diagonal"
function is_diag(line)
    a, b = line
    return abs(a.x - b.x) == abs(a.y - b.y)
end

"Include the line only if it is horizontal, vertical, or diagonal at 45 degrees"
is_valid(line) = is_hv(line) || is_diag(line)

"Return x & y coordinate iterator/ranges going from point `a` to `b`"
function ranges(a, b)
    Δ(s, t) = s < t ? 1 : -1
    xr = a.x == b.x ? Iterators.repeated(a.x, abs(a.y - b.y) + 1) : a.x:Δ(a.x, b.x):b.x
    yr = a.y == b.y ? Iterators.repeated(a.y, abs(a.x - b.x) + 1) : a.y:Δ(a.y, b.y):b.y
    return xr, yr
end

function run(input, filter_fn)
    lines = filter(filter_fn, input)
    max_x = maximum(max(a.x, b.x) for (a, b) in lines)
    max_y = maximum(max(a.y, b.y) for (a, b) in lines)
    # Use zero-based index easily!
    board = OffsetArray(zeros(Int, max_y + 1, max_x + 1), 0:max_y, 0:max_x)
    for (a, b) in lines
        for (x, y) in zip(ranges(a, b)...)
            board[y, x] += 1
        end
    end
    return count(>(1), board)
end

#=
sample_data = read_data("day05_sample.txt")
run(sample_data, is_hv)
run(sample_data, is_valid)

data = read_data("day05.txt")
run(data, is_hv)         # 4421
run(data, is_valid)      # 18674
=#

# Animation
using Plots

function chart1()
    input = read_data("day05.txt")
    lines = filter(is_valid, input)
    max_x = maximum(max(a.x, b.x) for (a, b) in lines)
    max_y = maximum(max(a.y, b.y) for (a, b) in lines)
    board = OffsetArray(zeros(Int, max_y + 1, max_x + 1), 0:max_y, 0:max_x)
    p = plot(; title = "Advent of Code 2021 - Day 5",
        legend = false, size = (500, 500))
    for (a, b) in lines
        p = plot!([a, b]; background = :black, foreground = :green,
            guidefontsize = 20, linewidth = 5, alpha = 0.2,
            guides = "", showaxis = false, ticks = false)
    end
    savefig("day05_lines.png")
    return p
end

function chart2()
    input = read_data("day05.txt")
    lines = filter(is_valid, input)
    max_x = maximum(max(a.x, b.x) for (a, b) in lines)
    max_y = maximum(max(a.y, b.y) for (a, b) in lines)
    board = zeros(Int, max_y + 1, max_x + 1)
    for (a, b) in lines
        for (x, y) in zip(ranges(a, b)...)
            board[y, x] += 1
        end
    end
    p = heatmap(board;
        title = "Advent of Code 2021 - Day 5",
        color = :thermal, legend = false, size = (500, 500),
        background = :black, foreground = :green)
    savefig("day05_heatmap.png")
    return p
end


function chart3()
    input = read_data("day05.txt")
    lines = filter(is_valid, input)
    max_x = maximum(max(a.x, b.x) for (a, b) in lines)
    max_y = maximum(max(a.y, b.y) for (a, b) in lines)
    board = zeros(Int, max_y + 1, max_x + 1)
    anim = Animation()
    plot(;
        title = "Advent of Code 2021 - Day 5",
        legend = false, size = (500, 500),
        background = :black, foreground = :green)
    frame(anim)
    for (i, (a, b)) in enumerate(lines)
        for (x, y) in zip(ranges(a, b)...)
            board[y, x] += 1
        end
        if i % 100 == 0
            heatmap!(board; color = :thermal)
            frame(anim)
            @info "Created frame $i"
        end
    end
    gif(anim, "day05_anim.png"; fps = 5)
end
