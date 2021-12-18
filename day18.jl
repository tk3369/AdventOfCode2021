using Test
using Combinatorics

mutable struct SnailfishNumber
    left::Union{SnailfishNumber, Int}
    right::Union{SnailfishNumber, Int}
end

function Base.show(io::IO, sf::SnailfishNumber)
    print(io, "[")
    if sf.left isa Int
        print(io, sf.left)
    elseif sf.left isa SnailfishNumber
        show(io, sf.left)
    end
    print(io, ",")
    if sf.right isa Int
        print(io, sf.right)
    elseif sf.right isa SnailfishNumber
        show(io, sf.right)
    end
    print(io, "]")
end

SnailfishNumber(s::String) = parse(SnailfishNumber, s)

"Parse a snailfish number"
function Base.parse(::Type{SnailfishNumber}, s::AbstractString)
    # Find the comma position that separate the left & right parts.
    # Keep track of depth by matching the brackets. If a comma is
    # encountered while deptyh = 0, then that's the pivot point.
    depth = 0
    comma_position = 0
    for (i, c) in enumerate(collect(s[2:end-1]))
        if c == ',' && depth == 0
            comma_position = i
            break
        end
        if c == '['
            depth += 1
        elseif c == ']'
            depth -= 1
        end
    end
    @assert comma_position != 0
    comma_position += 1   # since we ignored leading/trailing [ & ] before
    left = s[2:comma_position-1]
    right = s[comma_position+1:end-1]
    function _parse(x)
        if x[1] == '['  # it's an embedded snailfish number
            return parse(SnailfishNumber, x)
        else
            return parse(Int, x)
        end
    end
    return SnailfishNumber(_parse(left), _parse(right))
end

function find_exploding_pair(sf::SnailfishNumber, path = SnailfishNumber[], depth = 0)
    depth == 4 && return (; path, sf)
    left = sf.left isa Int ? nothing : find_exploding_pair(sf.left, [sf, path...], depth + 1)
    left !== nothing && return left
    right = sf.right isa Int ? nothing : find_exploding_pair(sf.right, [sf, path...], depth + 1)
    return right
end

function explode!(sf::SnailfishNumber)
    pair = find_exploding_pair(sf)
    pair === nothing && return false

    path, node = pair
    parent = path[1]
    if parent.left == node  # exploding left child
        parent.left = 0
        give!(parent, :rightchild, node.right)
        sibling_parent = find_sibling_tree_parent(node, path, :left)
        if sibling_parent !== nothing
            if sibling_parent.left isa Int
                sibling_parent.left += node.left
            else
                rightmost(sibling_parent.left).right += node.left
            end
        end
    else  # exploding right child
        parent.right = 0
        give!(parent, :leftchild, node.left)
        sibling_parent = find_sibling_tree_parent(node, path, :right)
        if sibling_parent !== nothing
            if sibling_parent.right isa Int
                sibling_parent.right += node.right
            else
                leftmost(sibling_parent.right).left += node.right
            end
        end
    end
    return true
end

function leftmost(sf::SnailfishNumber)
    if sf.left isa Int
        return sf
    else
        return leftmost(sf.left)
    end
end

function rightmost(sf::SnailfishNumber)
    if sf.right isa Int
        return sf
    else
        return rightmost(sf.right)
    end
end

# return the *parent* of the sibling tree
function find_sibling_tree_parent(me::SnailfishNumber, path::Vector{SnailfishNumber}, dir::Symbol)
    child = me
    for node in path
        if dir == :right
            if child == node.left
                return node
            end
        else
            if child == node.right
                return node
            end
        end
        child = node
    end
    return nothing
end

function give!(parent::SnailfishNumber, child::Symbol, value::Int, start = true)
    if child == :rightchild
        if parent.right isa Int
            parent.right += value
        else
            if start # switch just first time
                give!(parent.right, :leftchild, value, false)
            else
                give!(parent.right, :rightchild, value, false)
            end
        end
    else
        if parent.left isa Int
            parent.left += value
        else
            if start
                give!(parent.left, :rightchild, value, false)
            else
                give!(parent.left, :leftchild, value, false)
            end
        end
    end
end

function split_value(x::Int)
    v = x ÷ 2
    return (v, x - v)
end

function split!(sf::SnailfishNumber)
    done = false
    if sf.left isa SnailfishNumber
        done = split!(sf.left)
    elseif sf.left >= 10
        sf.left = SnailfishNumber(split_value(sf.left)...)
        return true
    end
    done && return true
    if sf.right isa SnailfishNumber
        done = split!(sf.right)
    elseif sf.right >= 10
        sf.right = SnailfishNumber(split_value(sf.right)...)
        return true
    end
    return done
end

function add(sf::SnailfishNumber, t)
    return SnailfishNumber("[" * string(sf) * "," * string(t) * "]")
end

function magnitude(sf::SnailfishNumber)
    left = 3 * (sf.left isa Int ? sf.left : magnitude(sf.left))
    right = 2 * (sf.right isa Int ? sf.right : magnitude(sf.right))
    return left + right
end

function read_data(filename)
    readlines(filename)
end

function simplify!(sf::SnailfishNumber)
    while true
        exploded = explode!(sf)
        if !exploded
            splitted = split!(sf)
            if !splitted
                break
            end
        end
    end
    return sf
end

function part1(input)
    sf = SnailfishNumber(input[1])
    for next in input[2:end]
        sf = add(sf, next)
        simplify!(sf)
    end
    return magnitude(sf)
end

function part2(input)
    nums = SnailfishNumber.(input)
    calc(x,y) = magnitude(simplify!(add(x,y)))
    maximum(max(calc(x,y), calc(y,x)) for (x,y) in combinations(nums, 2))
end

# ======= unit tests =======

function test_explode(input, expected)
    sf = parse(SnailfishNumber, input)
    explode!(sf)
    @test string(sf) == expected
end

function test_split(input, expected)
    sf = parse(SnailfishNumber, input)
    done = split!(sf)
    @test done
    @test string(sf) == expected
end

function unit_test()
    @testset "Snailfish Math" begin
        @testset "Explosion" begin
            test_explode("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]")
            test_explode("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]")
            test_explode("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]")
            test_explode("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
            test_explode("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
            # in the example with addition of [1,1]
            test_explode("[[[[0,7],4],[7,[[8,4],9]]],[1,1]]", "[[[[0,7],4],[15,[0,13]]],[1,1]]")
        end
        @testset "Split" begin
            test_split("[[[[0,7],4],[15,[0,13]]],[1,1]]", "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
            test_split("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]", "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
        end
    end
end

# ======= how to run =======

#=
part1(read_data("day18.txt))
part2(read_data("day18.txt))
=#
