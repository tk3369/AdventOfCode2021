using Combinatorics

const DIGITS = Dict(
    "abcefg" => 0,
    "cf" => 1,
    "acdeg" => 2,
    "acdfg" => 3,
    "bcdf" => 4,
    "abdfg" => 5,
    "abdefg" => 6,
    "acf" => 7,
    "abcdefg" => 8,
    "abcdfg" => 9,
)

function read_data(filename)
    split.(readlines(filename), " | ")
end

function part1(data)
    output = split.(getindex.(data, 2), " ")
    sum([count(x -> x in (2,3,4,7), length.(s)) for s in output])
end

function part2(data)
    total = 0
    for (input, output) in data
        input = split(input, " ")
        output = split(output, " ")
        oracle = find_solution(input)
        total += interpret(output, oracle)
    end
    return total
end

# Re-arrange letters in sorted form
rearrange(str::AbstractString) = join(sort(collect(str)))

# input is an array of "digits"
function find_solution(input::Vector{S}) where {S <: AbstractString}
    answer = sort(rearrange.(keys(DIGITS)))
    for (a, b, c, d, e, f, g) in permutations('a':'g', 7)
        mappings = [a => 'a', b => 'b', c => 'c', d => 'd', e => 'e', f => 'f', g => 'g']
        v = replace.(input, mappings...)
        if sort(rearrange.(v)) == answer
            return Dict(mappings...)
        end
    end
    @error "Cannot find answer :-("
end

function interpret(output::Vector{S}, oracle::Dict) where {S <: AbstractString}
    parse(Int, join(string(DIGITS[rearrange(replace(v, oracle...))]) for v in output))
end

#=
sample_data = read_data("day08_sample.txt")
part1(sample_data)
part2(sample_data)

data = read_data("day08.txt")
part1(data)
part2(data)
=#

