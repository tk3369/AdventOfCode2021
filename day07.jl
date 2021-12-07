function read_data(filename)
    parse.(Int, split(readlines(filename)[1], ","))
end

constant_cost(x, y) = abs(x - y)

function linear_cost(x, y)
    steps = abs(x - y)
    return steps * (steps + 1) ÷ 2
end

function calculate_fuel(positions, cost_func)
    n, m = extrema(positions)
    minimum(p -> sum(cost_func(p, d) for d in positions), n:m)
end

#=
sample_data = read_data("day07_sample.txt")
calculate_fuel(sample_data, constant_cost)
calculate_fuel(sample_data, linear_cost)

data = read_data("day07.txt")
calculate_fuel(data, constant_cost)
calculate_fuel(data, linear_cost)
=#
