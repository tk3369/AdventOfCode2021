function read_data(filename)
    lines = readlines(filename)
    coords = map.(xy, split.(lines, " -> "))
    map(c -> (c[1], c[2]), coords)
end

function xy(coord)
    v = parse.(Int, split(coord, ","))
    (x = v[1], y = v[2])
end

hv(line) = line[1].x == line[2].x || line[1].y == line[2].y

function is_diag(line)
    a, b = line
    abs(a.x - b.x) == abs(a.y - b.y)
end

function diag_range(line)
    a, b = line
    xinc = b.x > a.x ? 1 : -1
    yinc = b.y > a.y ? 1 : -1
    return a.x:xinc:b.x, a.y:yinc:b.y
end

function part1(input)
    lines = filter(hv, input)
    max_x = max(
        maximum(getproperty.(getindex.(lines, 1), :x)),
        maximum(getproperty.(getindex.(lines, 2), :x))
    )
    max_y = max(
        maximum(getproperty.(getindex.(lines, 1), :y)),
        maximum(getproperty.(getindex.(lines, 2), :y)),
    )
    @show max_x max_y
    M = zeros(Int, max_y + 1, max_x + 1)  # zero based coordinates
    for line in lines
        if line[1].x == line[2].x  # vertical
            y1 = min(line[1].y, line[2].y)+1
            y2 = max(line[1].y, line[2].y)+1
            M[y1:y2, line[1].x+1] .+= 1
        else  # y coordinates must equal, horizontal
            x1 = min(line[1].x, line[2].x)+1
            x2 = max(line[1].x, line[2].x)+1
            M[line[1].y+1, x1:x2] .+= 1
        end
    end
    return count(>(1), M) #, M
end

function part2(input)
    lines = input #filter(hv, input)
    max_x = max(
        maximum(getproperty.(getindex.(lines, 1), :x)),
        maximum(getproperty.(getindex.(lines, 2), :x))
    )
    max_y = max(
        maximum(getproperty.(getindex.(lines, 1), :y)),
        maximum(getproperty.(getindex.(lines, 2), :y)),
    )
    # @show max_x max_y
    M = zeros(Int, max_y + 1, max_x + 1)  # zero based coordinates
    for line in lines
        a, b = line
        if a.x == b.x  # vertical
            y1 = min(a.y, b.y)+1
            y2 = max(a.y, b.y)+1
            M[y1:y2, a.x+1] .+= 1
        elseif a.y == b.y # y coordinates must equal, horizontal
            x1 = min(a.x, b.x)+1
            x2 = max(a.x, b.x)+1
            M[a.y+1, x1:x2] .+= 1
        else
            @show r = diag_range(line)
            for (x,y) in zip(collect(r[1]), collect(r[2]))
                M[y+1, x+1] += 1
            end
        end
    end
    return count(>(1), M) #, M
end

#=
data = read_data("day05_sample.txt")
part1(data)
part2(data)

data = read_data("day05.txt")
part1(data)
=#