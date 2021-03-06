using StatsBase

function read_data(filename)
    data = transpose(parse.(Int, reduce(hcat, split.(readlines(filename), ""))))
    rows, cols = size(data)
    M = fill(99, rows+2, cols+2) # Add padding
    M[2:end-1, 2:end-1] = data
    return M
end

# Find low point by checking if the location's height is less than
# all of its neighbors.
# ans: 577
function count_lowest_locations(M)
    result = 0
    rows, cols = size(M)
    for i in 2:rows-1, j in 2:cols-1
        if  M[i, j] < M[i-1, j] &&
            M[i, j] < M[i+1, j] &&
            M[i, j] < M[i, j-1] &&
            M[i, j] < M[i, j+1]
            result += M[i, j] + 1
        end
    end
    return result
end

# Fill the region that is reachable from (i, j) with negative value x
# Note: x must be negative because it's used as an identifier for the region
# and I don't want to confuse with the high points.
function flood!(M, i, j, x)
    rows, cols = size(M)
    (M[i, j] in (9, 99) || M[i,j] < 0) && return
    M[i, j] = x
    i > 1    && flood!(M, i-1, j, x)
    i < rows && flood!(M, i+1, j, x)
    j > 1    && flood!(M, i, j-1, x)
    j < cols && flood!(M, i, j+1, x)
end

# Flood entire region and start with every cell.
# Note: this can be done more efficiently if we keep a map of processed cells.
function flood_basins!(M)
    id = -1
    rows, cols = size(M)
    for i in 2:rows-1, j in 2:cols-1
        flood!(M, i, j, id)
        if count(==(id), M) > 0
            id -= 1
        end
    end
    # Now all flooded regions has a unique negative id
    regions = [v for (k,v) in countmap(vec(M)) if k < 0]
    return prod(sort(regions, rev = true)[1:3])
end

#=
sample_data = read_data("day09_sample.txt")
count_lowest_locations(sample_data)
flood_basins!(sample_data)

data = read_data("day09.txt")
count_lowest_locations(data)
flood_basins!(data)
=#

using Plots

function make_image()
    M = read_data("day09.txt")
    anim = Animation()
    options = (
        title = "AoC Day 9: Into the Wilderness",
        size = (500, 500), background = :black, foreground = :green,
        showaxis = false, ticks = false, legend = false
    )
    heatmap(M; options...)
    id = -1
    rows, cols = size(M)
    for i in 2:rows-1, j in 2:cols-1
        flood!(M, i, j, id)
        flood_count = count(==(id), M)
        if flood_count > 0
            id -= 10
            if id % 11 == 0
                heatmap!(M; c = :greens, options...)
                frame(anim)
                @info "Making frame $id (i=$i, j=$j)"
            end
        end
    end
    gif(anim, "day09_anim.gif"; fps = 4)
end

# Inspirations

# JLing - using CartesianIndex
CI = CartesianIndex

# Calculate neighbor's coordinates
neighbors(coor) = [coor + c for c in (CI(0,1), CI(0,-1), CI(1,0), CI(-1,0))]

# Iterative algorithm
function walk(M, coor)
    size = 0
    todo = Set((coor, ))
    done = Set{CI}()
    while !isempty(todo)
        size += 1
        p = pop!(todo)
        push!(done, p)
        candidates = neighbors(p)
        for s in candidates
            s???done && M[s]<9 && (push!(todo, s))
        end
    end
    return size
end

# Jonathan Pallesen
using Pipe

function find_lowest_locations_jonathan_pallesen()
    read_matrix(data) = @pipe data .|> split(_, "") .|> parse.(Int, _) |> hcat(_...) |> permutedims

    moves = CartesianIndex.([(1,0), (0,1), (-1, 0), (0, -1)])

    # filter(in(board), _) comes back with valid coodinates, hence no padding needed
    adjacent(p, board) = @pipe moves .|> p + _ |> filter(in(board), _)
    smaller_than_neighbours(p, M, board) = all(adj -> M[adj] > M[p], adjacent(p, board))
    minimum_points(M, board) = filter(p -> smaller_than_neighbours(p, M, board), board)

    M = read_matrix(data)
    board = CartesianIndices(M)
    sum(p -> M[p] + 1, minimum_points(M, board))
end