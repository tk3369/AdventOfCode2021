using Statistics

function read_data(filename)
    readlines(filename)
end

function analyze(s, stack = "")
    opener = "([{<"
    closer = ")]}>"
    to_opener = Dict((v, k) for (k,v) in zip(opener, closer))
    corrupted_points = Dict(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)
    length(s) == 0 && return (0, stack)  # exhausted, incomplete line
    c, tail = first(s), s[2:end]
    if c in opener
        stack = "$(stack)$c"
        return analyze(tail, stack)
    else # must be a closer
        if to_opener[c] == stack[end] # matches?
            return analyze(tail, stack[1:end-1])
        else # bad closer, return points
            return (corrupted_points[c], stack)
        end
    end
end

# ans: 215229
part1(data) = sum(r[1] for r in analyze.(data))

function score(stack)
    opener = "([{<"
    closer = ")]}>"
    to_closer = Dict((k,v) for (k,v) in zip(opener, closer))
    complete_points = Dict(')' => 1, ']' => 2, '}' => 3, '>' => 4)
    total = 0
    for c in reverse(collect(stack))
        d = to_closer[c]
        total *= 5
        total += complete_points[d]
    end
    return total
end

function part2(data)
   return Int(median(sort(score.(last.(filter(x -> first(x) == 0, analyze.(data)))))))
end

#=
sample_data = read_data("day10_sample.txt")
part1(sample_data)
part2(sample_data)

data = read_data("day10.txt")
part1(data)
part2(data)
=#

# Inspirations

function score_using_fold(stack)
    opener = "([{<"
    closer = ")]}>"
    to_closer = Dict((k,v) for (k,v) in zip(opener, closer))
    complete_points = Dict(')' => 1, ']' => 2, '}' => 3, '>' => 4)
    foldl((a,b) -> 5a + b, (complete_points[to_closer[c]] for c in reverse(collect(stack))); init = 0)
end
