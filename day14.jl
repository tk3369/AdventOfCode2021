# using DataStructures
using StatsBase

function read_data(filename)
    lines = readlines(filename)
    str = lines[1]
    seed = unique_pairs(str)
    rules = Dict(split(x, " -> ") for x in lines[3:end])
    return str, seed, rules
end

# old code
function part1_step(seed, rules)
    s = "$(seed[1])"
    for i in 1:length(seed)-1
        prev, next = seed[i], seed[i+1]
        c = get(rules, (prev, next), nothing)
        updated = c !== nothing ? c * next : next
        s *= updated
    end
    s
end

function part1(seed, rules)
    s = seed
    for i in 1:10
        s = step(s, rules)
    end
    e = extrema(values(countmap(collect(s))))
    e[2] - e[1]
end

# debugging
function unique_pairs(s)
    countmap(s[i:i+1] for i in 1:length(s)-1)
end

function step!(dct, rules)
    for (k, cnt) in collect(dct)  # must use collect here to take a snapshot
        if haskey(rules, k)
            embed = rules[k]
            k1 = k[1] * embed
            k2 = embed * k[2]
            dct[k1] = get(dct, k1, 0) + cnt
            dct[k2] = get(dct, k2, 0) + cnt
            reduced = dct[k] - cnt
            reduced == 0 && pop!(dct, k)
            dct[k] = reduced
        end
    end
    return dct
end

function part2(str, seed, rules, steps)
    for s in 1:steps
        step!(seed, rules)
    end

    # How to count?
    # 1. The head of the string is special, the first letter is counted once
    # 2. For every pair, count the number of occurrences of the second letter
    dct = Dict{Char,Int}()
    dct[str[1]] = 1
    for (k, v) in seed
        dct[k[2]] = get(dct, k[2], 0) + v
    end
    return -(reverse(extrema(values(dct)))...)
end
