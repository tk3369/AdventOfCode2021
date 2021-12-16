using Graphs
using SparseArrays
using LinearAlgebra

function read_data(filename)
    collect(transpose(reduce(hcat, [parse.(Int, x) for x in split.(readlines(filename), "")])))
end

function make_graph(M)
    rows, cols = size(M)  # there should be rows x cols number of nodes
    nv = rows * cols
    I, J, V = Int[], Int[], Int[]
    edges = Edge{Int}[]
    for r in 1:rows, c in 1:cols
        me = (c - 1) * rows + r  # my own vertex id
        right = c * rows + r     # right neighbor
        bottom = me + 1          # bottom neighbor
        left = me - rows
        top = me - 1
        if c < cols   # don't do last col
            push!(edges, Edge(me, right))
            push!(I, me); push!(J, right); push!(V, M[r, c + 1])
        end
        if r < rows  # don't do last row
            push!(edges, Edge(me, bottom))
            push!(I, me); push!(J, bottom); push!(V, M[r + 1, c])
        end
        if c > 1
            push!(edges, Edge(me, left))
            push!(I, me); push!(J, left); push!(V, M[r, c - 1])
        end
        if r > 1
            push!(edges, Edge(me, top))
            push!(I, me); push!(J, top); push!(V, M[r - 1, c])
        end
    end
    dist = sparse(I, J, V)
    g = SimpleDiGraph(edges)
    return g, dist
end

# Seems memory intensive, ideally a custom array type could work better.
"Create a 5x5 big map with the provided tile `M`."
function big_map(M)
    rows, cols = size(M)
    N = zeros(Int, 5rows, 5cols)
    row_start_matrix = M
    for tile_row in 0:4
        tile_matrix = copy(row_start_matrix)
        for tile_col in 0:4
            r = tile_row * rows + 1
            c = tile_col * cols + 1
            N[r:r+rows-1, c:c+cols-1] .= tile_matrix
            tile_matrix = next(tile_matrix)
        end
        row_start_matrix = next(row_start_matrix)
    end
    return N
end

"Find the shortest path in the graph from start (vertex 1) to end (vertex N)"
function find_shortest_path(input)
    g, distmx = make_graph(input)
    rows, cols = size(input)
    sum(distmx[edge.src, edge.dst] for edge in a_star(g, 1, rows * cols, distmx))
end

"Return the next higher up matrix with wrapping from 9 to 1"
function next(M)
    [M[idx] == 9 ? 1 : M[idx] + 1 for idx in CartesianIndices(M)]
end

#=
data = read_data("day15.txt")
bm = big_map(data)
find_shortest_path(bm)
=#