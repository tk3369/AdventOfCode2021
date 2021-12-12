function read_data(filename)
    mappings = Dict()
    for (from, to) in split.(readlines(filename), "-")
        set = get!(mappings, from, Set{String}())
        to != "start" && from != "end" && push!(set, to)
        from, to = to, from  # swap roles and do again
        set = get!(mappings, from, Set{String}())
        to != "start" && from != "end" && push!(set, to)
    end
    return mappings
end

# Keep a Set to make sure that large cave does not get visited more than once
# Use DFS
is_large(s) = all(isuppercase.(collect(s)))
is_small(s) = !is_large(s)

function paths(edges::Dict, node::String = "start", visited = Set{String}(), path = String[], level = 1; found = [])
    indent = "  " ^ level
    next_candidates = edges[node]
    next_caves = setdiff(next_candidates, visited)

    # @info "$indent called: $node visited=$visited next_candidates=$next_candidates path=$path"

    is_small(node) && push!(visited, node)
    push!(path, node)

    if node == "end"
        full_path = join(path, ",")
        # @info "$indent Found path: $full_path"
        push!(found, full_path)
        pop!(path)
        return 1
    end

    len = length(next_caves)
    if len == 0 # dead end
        # @info "$indent Dead end: node=$node path=$path"
        return 0
    else
        # sleep(0.2)
        total = 0
        for c in next_caves
            visited_copy = copy(visited)
            path_copy = copy(path)
            total += paths(edges, c, visited_copy, path_copy, level+1; found)
            # @info "$indent Cave stat: $c visited_copy=$visited_copy path_copy=$path_copy"
        end
        return total
    end
end

function part2(data)
end


#=
sample_data = read_data("day12_sample.txt")
part1(sample_data)
part2(sample_data)

data = read_data("day12.txt")
part1(data)
part2(data)
=#
