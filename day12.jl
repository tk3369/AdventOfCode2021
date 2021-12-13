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

is_small(s) = all(islowercase, collect(s))

"""
Calculate all distinct paths.

# Arguments
- `edges`: input data
- `allowance`: if true, let one small cave to pass through twice (part 2)
- `node`: current node in the walk
- `visited`: track which caves have been visited before
- `level`: DFS level (useful for debugging only)
- `twice`: whether a small cave has been visited twice before
- `found`: all found paths
"""
function calculate_paths(edges::Dict, allowance = false,
    node::String = "start", visited = Set{String}(), path = String[], level = 1, twice = false, found = []
)
    next_candidates = edges[node]

    # Next caves are the ones that I haven't visited before
    next_caves = [(c, false) for c in setdiff(next_candidates, visited)]

    # For part2, if we haven't seen a cave passed through twice yet, we can add back those skipped caves.
    # Use a flag to remember the fact that it's been just added back to the list.
    if allowance && !twice
        skipped_caves = [(c, is_small(c) ? true : false) for c in intersect(visited, next_candidates)]
        union!(next_caves, skipped_caves)
    end

    # Just need to push the current node to the visited list
    if is_small(node)
        push!(visited, node)
    end

    # Keep track of the path
    push!(path, node)

    # If I have just hit the end, great! Determine the path value and update `found`.
    if node == "end"
        full_path = join(path, ",")
        push!(found, full_path)
        return (found, 1)
    end

    len = length(next_caves)
    if len == 0
        # if there is no more cave, then we must have hit a dead end.
        return (found, 0)
    else
        # Use DFS to explore next set of caves.
        total = 0
        for (c, flag) in next_caves
            # Before going down the stack, use a copy of mutable data
            visited_copy = copy(visited)
            path_copy = copy(path)
            # This is important - the `twice` variable needs to "propagate" down the stack.
            twice_flag = twice || flag
            _, cnt = calculate_paths(edges, allowance, c, visited_copy, path_copy, level+1, twice_flag, found)
            total += cnt
        end
        return (found, total)
    end
end

#=
data = read_data("day12.txt")
calculate_paths(data, false)[2]    # 3761
calculate_paths(data, true)[2]     # 99138
=#

# Inspirations

# Clean and easy to understand DFS algorithm
module Sukera

function input(file)
    nodes = Dict{String, Vector{String}}()
    for line in eachline(file)
        a,b = split(line, '-')
        (a != "end" && b != "start") && push!(get!(() -> String[], nodes, a), b)
        (b != "end" && a != "start") && push!(get!(() -> String[], nodes, b), a)
    end
    nodes
end

part_one(nodes) = dfs(nodes, ["start"], chooseNode1)
part_two(nodes) = dfs(nodes, ["start"], chooseNode2)

chooseNode1(n,path) = all(isuppercase,n) || !(n in path)
function chooseNode2(n,path)
    all(isuppercase,n) && return true
    if n in path
        for node in path
            all(isuppercase, node) && continue
            (count(==(node), path) == 2) && return false
        end
    end
    return true
end

function dfs(nodes, path, filterfunc)
    curNode = last(path)
    curNode == "end" && return 1
    neighbors = Iterators.filter(n -> filterfunc(n, path), nodes[curNode])
    paths = 0
    for n in neighbors
        paths += dfs(nodes, push!(path, n), filterfunc)
        pop!(path)
    end
    return paths
end

end #module


# Solve part 1 & 2 at the same time
module JakobNyboNissan

function parse(io::IO)::Dict{String, Set{String}}
    d = Dict{String, Set{String}}()
    for line in eachline(io)
        a, b = split(line, '-')
        b == "start" || push!(get!(valtype(d), d, a), b)
        a == "start" || push!(get!(valtype(d), d, b), a)
    end
    d
end

solve(io::IO) = solve(parse(io))
function solve(d::Dict)
    stack = [(Set{String}(), false, "start")]
    paths_extravisit = 0
    paths_novisit = 0
    while !isempty(stack)
        hasbeen, small_visited, now = pop!(stack)
        for i in d[now]
            if i == "end"
                paths_novisit += !small_visited
                paths_extravisit += 1
                continue
            end
            visitsmall = all(islowercase, i)
            hasvisited = visitsmall && i ∈ hasbeen
            if hasvisited && small_visited
                continue
            end
            news = visitsmall ? push!(copy(hasbeen), i) : copy(hasbeen)
            push!(stack, (news, small_visited || hasvisited, i))
        end
    end
    return (paths_novisit, paths_extravisit)
end

end #module