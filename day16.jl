function read_data(filename)
    readlines(filename)
end

"Given an 8-bit string, return the lower 4 bits."
lower_bits(s) = s[5:end]

"Convert a hex number string into a bitstring"
to_bits(s) = join(lower_bits.(bitstring.(parse.(UInt8, split(s, ""); base = 16))))

"Convert a bitstring into an integer"
dec(s) = parse(Int, s; base = 2)

"BITS transmission"
struct BITS end

"BITS literal"
struct Literal end

"""
Parse a single BITS literal, starting from position `p` in the string `s`.
Returns the value in decimal and the character position right after the
end of the literal in the string.
"""
function Base.parse(::Type{Literal}, s::AbstractString, p = 1)
    v = ""
    while p <= length(s)
        bit = s[p]  # leading indicator: 1=has more, 0=last group
        v *= s[p+1:p+4]
        p += 5      # next group
        bit == '0' && break
    end
    return (value = dec(v), str = v, next_pos = p)
end

"""
Parse a BITS transmission. There are two kinds: fixed (exact number of packets) or
bits (exact number of bits in the following packets). The `num` argument is relevant
to that specific kind. Argument `p` represents the starting position of the string.
"""
function Base.parse(::Type{BITS}, s::AbstractString, kind = :fixed, num = 1, p = 1)
    packets = []
    cnt = 0     # keeps track of number of packets parsed so far
    start = p   # remembers the original starting position
    while true
        kind == :fixed && cnt == num && break
        kind == :bits && (p >= start + num) && break
        version = dec(s[p:p+2])
        type_id = dec(s[p+3:p+5])
        if type_id == 4  # literal
            literal = parse(Literal, s, p+6)
            packet = (; version, type_id, value = literal.value, packets = [])
            p = literal.next_pos
        else # operator
            bit = s[p+6]
            if bit == '0'  # total length in bits (next 15 bits)
                sub_packets_length = dec(s[p+7:p+7+15-1])
                sub_packets, p = parse(BITS, s, :bits, sub_packets_length, p+7+15)
                packet = (; version, type_id, literal = 0, packets = sub_packets)
            else           # number of sub-packets (next 11 bits)
                num_sub_packets = dec(s[p+7:p+7+11-1])
                sub_packets, p = parse(BITS, s, :fixed, num_sub_packets, p+7+11)
                packet = (; version, type_id, literal = 0, packets = sub_packets)
            end
        end
        push!(packets, packet)
        cnt += 1
    end
    return packets, p
end

"Calculate sum of all versions in the packets"
function sum_versions(x)
    if x isa AbstractArray
        return length(x) > 0 ? sum(sum_versions(v) for v in x) : 0
    else
        return x.version + sum_versions(x.packets)
    end
end

"Return the aggregated value of the BITS transmission"
function value(x)
    if x.type_id == 4
        return x.value
    else
        if x.type_id == 0
            return sum(value(v) for v in x.packets)
        elseif x.type_id == 1
            return prod(value(v) for v in x.packets)
        elseif x.type_id == 2
            return minimum(value(v) for v in x.packets)
        elseif x.type_id == 3
            return maximum(value(v) for v in x.packets)
        elseif x.type_id == 5
            v1, v2 = value(x.packets[1]), value(x.packets[2])
            return v1 > v2 ? 1 : 0
        elseif x.type_id == 6
            v1, v2 = value(x.packets[1]), value(x.packets[2])
            return v1 < v2 ? 1 : 0
        elseif x.type_id == 7
            v1, v2 = value(x.packets[1]), value(x.packets[2])
            return v1 == v2 ? 1 : 0
        else
            error("wat???")
        end
    end
end

function part1(input)
    s = to_bits(input)
    operations = parse(BITS, s)[1][1]
    return sum_versions(operations)
end

function part2(input)
    s = to_bits(input)
    operations = parse(BITS, s)[1][1]
    return value(operations)
end