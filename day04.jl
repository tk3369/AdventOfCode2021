function read_data(file)
    lines = readlines(file)
    draws = parse.(Int, split(lines[1], ","))
    boards = []
    for i in 3:6:length(lines)-1
        M = zeros(Int, 5, 5)
        for r in 1:5
            M[r, :] = parse.(Int, split(strip(lines[i+r-1]), r" +"))
        end
        push!(boards, M)
    end
    return draws, boards
end

# Keep track of board state
make_state() = zeros(Int, 5, 5)
make_states(n) = [make_state() for _ in 1:n]

"Mark a board for the drawn number `val`"
function mark(board, state, val)
    for i in 1:5, j in 1:5
        if board[i,j] == val
            state[i,j] = 1
        end
    end
end

"Return true if the board state has any fully-marked row/column"
function won(state)
    any(==(5), sum(state, dims = 1)) ||
    any(==(5), sum(state, dims = 2))
end

"Return sum of board values where it was unmarked"
function sum_of_unmarked(board, state)
    sum(b for (b, s) in zip(board, state) if s == 0)
end

function part1(draws, boards)
    states = make_states(length(boards))
    for val in draws
        for (board, state) in zip(boards, states)
            mark(board, state, val)
        end
        for (i, state) in enumerate(states)
            if won(state)
                return sum_of_unmarked(boards[i], state) * val
            end
        end
    end
end

function part2(draws, boards)
    states = make_states(length(boards))
    winners = Set()
    for val in draws
        for (board, state) in zip(boards, states)
            mark(board, state, val)
        end
        for (i, state) in enumerate(states)
            if won(state)
                push!(winners, i)
                if length(winners) == length(boards)
                    return sum_of_unmarked(boards[i], state) * val
                end
            end
        end
    end
end

# Benchmarking

#=
julia> draws, boards = read_data("day04.txt");

julia> @btime part1($draws, $boards);
  1.126 ms (19945 allocations: 904.41 KiB)

julia> @btime part2($draws, $boards);
  2.539 ms (41151 allocations: 1.89 MiB)
=#

# Revised after solving the puzzle

@enum Rank FirstWinner LastWinner

function play(draws, boards, ranking::Rank)
    num_players = length(boards)
    states = make_states(num_players)
    players = trues(num_players)
    position = ranking == FirstWinner ? 1 : num_players
    for val in draws
        for (i, (board, state)) in enumerate(zip(boards, states))
            players[i] && mark(board, state, val)
        end
        for (i, state) in enumerate(states)
            if players[i] && won(state)
                players[i] = false    # getting out of game
                if count(==(0), players) == position
                    return sum_of_unmarked(boards[i], state) * val
                end
            end
        end
    end
end

part1_revised(draws, boards) = play(draws, boards, FirstWinner)
part2_revised(draws, boards) = play(draws, boards, LastWinner)

# Animation

using Formatting

# ANSI escape sequences
# See https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
clear() = print("\e[2J")
home() =  print("\e[H")
show_cursor() = print("\e[?25h")
hide_cursor() = print("\e[?25l")
set_color(c) = print("\e[38;5;$(c)m")
reset_color() = print("\e[38;5;255m")

# Print the boards with marked numbers
function print_boards(boards, states)
    color_palette = [226, 196, 118]
    gap = "   "
    for row in 1:5
        for (i, (board, state)) in enumerate(zip(boards, states))
            for col in 1:5
                board_color = color_palette[i]
                state[row, col] == 1 && set_color(board_color)
                printfmt("{:>3d}", board[row, col])
                reset_color()
            end
            print(gap)
        end
        println()
    end
    println()
end

function animate_game()
    hide_cursor()
    clear()
    home()
    draws, boards = read_data("day04_sample.txt")
    num_players = length(boards)
    states = make_states(num_players)
    winner = 0
    print_boards(boards, states)
    for val in draws
        home()
        sleep(0.5)
        for (board, state) in zip(boards, states)
            mark(board, state, val)
        end
        print_boards(boards, states)
        for (i, state) in enumerate(states)
            if won(state)
                winner = i
                break
            end
        end
        winner > 0 && break
    end
    show_cursor()
    println("Winner is board #$winner")
end

# How did I convert mov to animated gif?
#   ffmpeg -i day04.mov -pix_fmt rgb24 -r 10 -vf tpad=stop_mode=clone:stop_duration=3 day04.gif
#
# References:
#  https://superuser.com/questions/436056/how-can-i-get-ffmpeg-to-convert-a-mov-to-a-gif
#  https://video.stackexchange.com/questions/10825/how-to-hold-the-last-frame-when-using-ffmpeg


# Inspring community solutions

# JLing
# 1. Splitting input by double newline
# 2. Using mapreduce to parse the matrix from input (btw, transpose not needed for this problem)
# 3. Comparing row/columns of 5's with eachrow/eachcol
# 4. Turning numbers into -1 so they can be marked and ignored later (not a big fan but interesting nonetheless)
#=
Jling: I can't help but golfing, 17 lines solution to both parts:

inputs = split(strip(read("./input4", String), '\n'), "\n\n")
draws = parse.(Int, split(inputs[1], ","))
boards = map(inputs[2:end]) do board
    parse.(Int, mapreduce(split, hcat, split(board, "\n")))
end
p = fill(-1,5)
wincon(m) = any(==(p), eachrow(m)) || any(==(p), eachcol(m))

# part 1 & 2
done = Set{Int}()
res = Int[]
for num in draws, (i, b) in enumerate(boards)
    replace!(b, num => -1)
    if i∉done && wincon(b)
        push!(done, i)
        push!(res, num * sum(filter(>(0), b)))
    end
end
println(res[[begin, end]])
=#
