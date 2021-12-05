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
is_hv(line) = let (a, b) = line
    a.x == b.x || a.y == b.y
end

"Returns true if the line is diagonal"
is_diag(line) = let (a, b) = line
    abs(a.x - b.x) == abs(a.y - b.y)
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
    max_x = maximum(max(a.x, b.x) for (a,b) in data)
    max_y = maximum(max(a.y, b.y) for (a,b) in data)
    M = zeros(Int, max_y + 1, max_x + 1)  # zero based coordinates
    for (a, b) in lines
        xr, yr = ranges(a, b)
        for (x,y) in zip(collect(xr), collect(yr))
            M[y+1, x+1] += 1
        end
    end
    return count(>(1), M)
end

#=
sample_data = read_data("day05_sample.txt")
run(sample_data, is_hv)
run(sample_data, is_valid)

data = read_data("day05.txt")
run(data, is_hv)         # 4421
run(data, is_valid)      # 18674
=#