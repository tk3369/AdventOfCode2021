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

function part1()
    draws, boards = read_data("day04.txt")
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

function part2()
    draws, boards = read_data("day04.txt")
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

# Revised after solving the puzzle

@enum Rank FirstWinner LastWinner

function play(ranking::Rank)
    draws, boards = read_data("day04.txt")
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

part1_revised() = play(FirstWinner)
part2_revised() = play(LastWinner)
