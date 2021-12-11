using LinearAlgebra
CI = CartesianIndex

function read_data(filename)
    transpose(parse.(Int, reduce(hcat, split.(readlines(filename), ""))))
end

function up!(octopuses, board, c)
    if c ∈ board && octopuses[c] < 10
        octopuses[c] += 1
    end
end

# Run program
function main(octopuses; steps = 100, part = 1, callback = (x,i)->nothing)
    octopuses = copy(octopuses)  # no side effect
    board = CartesianIndices(data)
    around = [CI(-1,-1), CI(0,-1), CI(1,-1), CI(-1,0), CI(1,0), CI(-1,1), CI(0,1), CI(1,1)]
    flashes = 0
    for i in 1:steps
        octopuses[board] .+= 1
        flashed = Set{CI}()
        while true
            # Find new octopuses that will flash
            initiators = findall(==(10), octopuses)
            setdiff!(initiators, flashed)

            # break if there is no more octopuses to flash in this step
            length(initiators) == 0 && break

            # remember these octopuses
            union!(flashed, initiators)

            # for part 1, increment counter
            flashes += length(initiators)

            # increase all neighbors' energy by 1
            neighbors = filter(in(board), reduce(vcat, [around .+ Ref(c) for c in initiators]))
            up!.(Ref(octopuses), Ref(board), neighbors)
        end

        # Reset flashed octopuses
        octopuses[findall(==(10), octopuses)] .= 0

        # for animation, call back user provided function
        callback(octopuses, i)

        # for part 2, all octopuses are shining at the same time!
        if part == 2 && sum(octopuses[board]) == 0
            return "part2: step $i"
        end
    end
    return "part1: $flashes"
end

#=
julia> data = read_data("day11.txt")
10×10 transpose(::Matrix{Int64}) with eltype Int64:
 3  2  6  5  2  5  5  2  7  6
 1  5  3  7  4  1  2  6  6  5
 7  3  3  5  7  4  6  4  2  2
 6  4  2  6  3  2  5  6  5  8
 3  8  5  4  4  3  4  3  6  4
 8  7  1  7  3  7  7  4  8  6
 4  5  2  2  2  8  6  3  2  6
 6  3  3  7  7  7  2  8  4  5
 8  8  2  4  3  8  7  6  6  5
 6  3  5  1  5  8  6  4  8  4

julia> main(data, steps = 100, part = 1)
"part1: 1627"

julia> main(data, steps = 10000, part = 2)
"part2: step 329"
=#

using Plots
using Luxor

# heatmap version
function make_animation()
    data = read_data("day11.txt")
    anim = Animation()
    options = (
        title = "AoC Day 11: ", c = :thermal, size = (400, 400),
        legend = false, background = :black, foreground = :green,
        showaxis = false, ticks = false)
    heatmap(data; options...)
    frame(anim)
    function cb(M, i)
        heatmap!(M; options...)
        frame(anim)
    end
    main(data; steps = 329, part = 2, callback = cb)
    gif(anim, "day11_anim.gif", fps = 10)
end

# Text version
using Formatting

# ANSI escape sequences
# See https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
clear() = print("\e[2J")
home() =  print("\e[H")
show_cursor() = print("\e[?25h")
hide_cursor() = print("\e[?25l")
set_color(c) = print("\e[38;5;$(c)m")
reset_color() = print("\e[38;5;255m")

function aquarium(octopuses, step)
    color_palette = [42, 43, 44, 45, 45, 217, 218, 219, 202, 203]
    rows, cols = size(octopuses)
    home()
    set_color(196)
    pad1 = "   "
    pad2 = "     "
    println()
    println("$(pad1)AoC Day 11: Colorful Octopuses ($step)")
    println()
    for r in 1:rows
        for c in 1:cols
            val = octopuses[r, c]
            set_color(color_palette[val % 10 + 1])
            c == 1 && print("$pad2")
            printfmt("{:>3d}", val)
            reset_color()
        end
        println()
    end
end

# Use Quick Time Player to capture video
# Then, convert to animated gif using ffmpeg:
# ffmpeg -i day11.mov -pix_fmt rgb8 -r 10 -vf "scale=iw/4:ih/4,tpad=stop_mode=clone:stop_duration=3,setpts=0.4*PTS" day11_anim.gif
function make_text_animation()
    data = read_data("day11.txt")
    function cb(M, i)
        aquarium(M[2:end-1, 2:end-1], i)
        sleep(0.05)
    end
    clear()
    hide_cursor()
    sleep(5)
    main(data; steps = 329, part = 2, callback = cb)
    show_cursor()
end