# using DataStructures
using StatsBase

function read_data(filename)
    lines = readlines(filename)
    str = lines[1]
    seed = countmap(str[i:i+1] for i in 1:length(str)-1)
    rules = Dict(split(x, " -> ") for x in lines[3:end])
    return str, seed, rules
end

function step!(dct, rules)
    for (k, cnt) in copy(dct)  # must take a snapshot
        if haskey(rules, k)
            embed = rules[k]
            k1, k2 = k[1] * embed, embed * k[2]  # derive new pairs
            dct[k1] = get(dct, k1, 0) + cnt      # increment counters
            dct[k2] = get(dct, k2, 0) + cnt
            reduced = dct[k] - cnt               # original one must be reduced
            reduced == 0 && pop!(dct, k)         # do not keep any zeroes
            dct[k] = reduced
        end
    end
end

function expand(str, seed, rules, steps)
    counters = copy(seed)  # avoid side effect
    for s in 1:steps
        step!(counters, rules)
    end
    # How to count?
    # 1. The head of the string is special, the first letter is counted once
    # 2. For every pair, count the number of occurrences of the second letter
    dct = Dict{Char,Int}()
    dct[str[1]] = 1
    for (k, v) in counters
        dct[k[2]] = get(dct, k[2], 0) + v
    end
    return -(reverse(extrema(values(dct)))...)
end

#=
str, seed, rules  = read_data("day14.txt")
expand(str, seed, rules, 40)
=#