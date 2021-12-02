"""
    command_parser(args...; sep = " ")

Return a function that parses a line of text and return a named tuple.

# Example
```julia
julia> parser = command_parser(:cmd, String, :x, Int)
#127 (generic function with 1 method)

julia> parser.(["hey 1", "world 2"])
2-element Vector{NamedTuple{(:cmd, :x), Tuple{SubString{String}, Int64}}}:
 (cmd = "hey", x = 1)
 (cmd = "world", x = 2)
```
"""
function command_parser(args...; sep = " ")
    iseven(length(args)) || error("Should have even number of arguments")
    num_fields = length(args) ÷ 2
    names = Symbol.(args[1:2:end])
    funcs = map(args[2:2:end]) do T
        T <: AbstractString ? identity :
        T <: Number ? x -> parse(T, x) :
        error("bad type")
    end
    return function(line)
        fields = split(line, sep)
        values = [func(f) for (func, f) in zip(funcs, fields)]
        return NamedTuple{tuple(names...)}(tuple(values...))
    end
end