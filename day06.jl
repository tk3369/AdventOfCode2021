using OffsetArrays

function read_data(filename)
    parse.(Int8, split(readlines(filename)[1], ","))
end

# Naive solution
function part1(data)
    for i in 1:256
        data .-= 1
        for j in 1:length(data)
            if data[j] == -1
                data[j] = 6
                push!(data, 8)
            end
        end
    end
    length(data)
end

# Notes for Part2.
# I spent a lot of time in part2 to formulate the problem into a recursive
# algorithm and debuging. After the algorithm was good, it was too slow and
# I ended up adding a matrix to memoize previous results.

part2(fishes, days) = sum(family(fish, 1, days) for fish in fishes)

"""
    spawns(life, next_day, armageddon)

Calculate the days when new fishes are spawn in `n` days given the
fish has life of `x` days on day `d-1`.
"""
spawns(life, next_day, armageddon) = (life + next_day):7:armageddon

"""
    family(life, next_day, armageddon, M)

Find how many fishes in this family. Use a matrix for fast lookup.
"""
function family(
    life, next_day, armageddon,
    M = OffsetArray(zeros(BigInt, 9, 257), 0:8, 1:257)
)
    M[life, next_day] > 0 && return M[life, next_day]
    kids = BigInt[family(8, day+1, armageddon, M) for day in spawns(life, next_day, armageddon)]
    total = 1 + sum(kids)
    M[life, next_day] = total
    return total
end

#=
sample_data = read_data("day06_sample.txt")
part1(sample_data)
part2(sample_data)

data = read_data("day06.txt")
part1(data)
part2(data)
=#

# Inspirations

# JLing
module JLing

function run(input, days)
    counts = zeros(Int, 10)
    @. counts[input+2] += 1
    for _ = 1:days
        counts = circshift(counts, -1)
        N_mature = first(counts)
        counts[end] = N_mature
        counts[6+2] += N_mature
    end
    sum(counts[2:end])
end

end #module

module Kirill
const m1 = [0 1 0 0 0 0 0 0 0
            0 0 1 0 0 0 0 0 0
            0 0 0 1 0 0 0 0 0
            0 0 0 0 1 0 0 0 0
            0 0 0 0 0 1 0 0 0
            0 0 0 0 0 0 1 0 0
            1 0 0 0 0 0 0 1 0
            0 0 0 0 0 0 0 0 1
            1 0 0 0 0 0 0 0 0]
const m80 = m1 ^ 80
const m256 = m1 ^ 256

function solve1(input, m = m80)
    v = zeros(Int, 9)
    for g in input
        v[g + 1] += 1
    end
    sum(m * v)
end

solve2(input) = solve1(input, m256)

function run(input)
    output1 = solve1(input)
    output2 = solve2(input)
    return output1, output2
end

end #module

module Rolfe

# 1.083 μs (1 allocation: 128 bytes)
function run(initial_state, days)
    counts = zeros(Int64, 9)
    for counter in initial_state
        counts[counter + 1] += 1
    end
    for _ in 1:days
        num_new = counts[1]
        for k = 1:8
            counts[k] = counts[k+1]
        end
        counts[7] += num_new
        counts[9] = num_new
    end
    return reduce(+, counts)
end

end #module