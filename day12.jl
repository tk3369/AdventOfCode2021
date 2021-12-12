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

function paths(edges::Dict, node::String = "start", visited = Dict{String,Int}(), path = String[], level = 1; found = [])
    indent = "  " ^ level
    next_candidates = edges[node]

    @info "$indent called: $node visited=$visited next_candidates=$next_candidates path=$path"

    # add back visited caves as long as the existing visited count == 1
    next_caves = setdiff(next_candidates, keys(visited))
    skipped_caves = intersect(keys(visited), next_candidates)
    for cave in skipped_caves
        if is_small(cave) && cave != "start" && cave != "end" && visited[cave] == 1
            push!(next_caves, cave)
            visited[cave] = 2
            break
        end
    end
    @info "$indent next_caves: $next_caves visited=$visited"

    if is_small(node) && get(visited, node, 0) == 0
        visited[node] = 1
    end

    push!(path, node)

    if node == "end"
        full_path = join(path, ",")
        @info "$indent Found path: $full_path"
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
