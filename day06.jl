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
    spawns(x, d, n)

Calculate the days when new fishes are spawn in `n` days given the
fish has life of `x` days on day `d-1`.
"""
@inline spawns(life, next_day, armageddon) = (life + next_day):7:armageddon

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