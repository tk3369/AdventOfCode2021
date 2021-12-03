function read_data(file)
    return transpose(parse.(Int, hcat(collect.(readlines(file))...)))
end

"Convert a bitstring to a decimal number"
dec(str) = parse(Int, str; base = 2)

"What digit is most common at column `j`?"
function most_common(M, j)
    rows = size(M, 1)
    num_ones = sum(M[:, j]) 
    num_zeros = rows - num_ones
    return num_ones >= num_zeros ? 1 : 0
end

least_common(M, j) = xor(most_common(M, j), 1)

# ans: 2724524
function part1()
    M = read_data("day03.txt")
    num_cols = size(M, 2)
    gamma = join(string(most_common(M, j)) for j in 1:num_cols)
    epsilon = join(string(least_common(M, j)) for j in 1:num_cols)
    return dec(gamma) * dec(epsilon)
end

"Slice the matrix by selecting rows that has `bit` at column `j`."
function slice_by_bit(M, j, bit)
    match_indices = M[:, j] .== bit
    return M[match_indices, :]
end

"Go through the slice process until a single row is nailed."
function find_factor(M, algo::Function)
    pos = 1
    while true
        bit = algo(M, pos)
        M = slice_by_bit(M, pos, bit)
        size(M, 1) == 1 && break
        pos += 1
    end
    return join(string(x) for x in M)
end

# ans: 2775870
function part2()
    input = read_data("day03.txt")
    oxygen = find_factor(input, most_common)
    co2 = find_factor(input, least_common)
    return dec(oxygen) * dec(co2)
end

