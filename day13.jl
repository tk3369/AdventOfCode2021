using SparseArrays
using Plots

function read_data(filename)
    data = String(read(filename))
    coords, folds = split(data, "\n\n")
    prs(v) = parse(Int, v)
    coords = [(prs(x), prs(y)) for (x,y) in split.(split(coords, "\n"), ",")]
    mth(s) = let x = match(r"fold along (.)=(\d+)", s)
        (axis = x.captures[1], pos = parse(Int, x.captures[2]))
    end
    folds = [mth(f) for f in split(folds, "\n")]
    return (; coords, folds)
end

function play(input, nfolds)
    coords = input.coords
    for (i, f) in enumerate(input.folds)
        paper = []
        for c in coords
            if f.axis == "y"  # fold up
                if c[2] > f.pos
                    delta = c[2] - f.pos
                    push!(paper, (c[1], c[2] - 2 * delta))
                else
                    push!(paper, c)
                end
            else  # fold left
                if c[1] > f.pos
                    delta = c[1] - f.pos
                    push!(paper, (c[1] - 2 * delta, c[2]))
                else
                    push!(paper, c)
                end
            end
        end
        coords = paper
        i >= nfolds && break
    end
    return unique(coords)
end

function find_code(cs)
    A = sparse(getindex.(cs, 1) .+ 1, getindex.(cs, 2) .+ 1, ones(length(cs)))
    M = collect(transpose(A))
    # flip it vertically so I can see if more clearly
    M = M[end:-1:1, :]
    M, heatmap(M, size=(1000, 300), c=:lightrainbow)
end

#=
data = read_data("day13.txt")
p1 = play(data, 1)
p2 = play(data, typemax(Int))
M, plt = find_code(p2)
=#


function make_animation(M)
    rows, cols = size(M)

    # Create my own color scheme
    cs = ColorScheme(vcat(
        range(colorant"black", colorant"red", length=5),
        range(colorant"red", colorant"green", length=5))
    )

    # random color where 0.5 and 1.0 represent red and green respectively
    randcolor() = rand([0.5, 1.0])

    # randomize red/green colors
    randomize(M) = [M[r,c] > 0 ? randcolor() : 0 for r in 1:rows, c in 1:cols]

    options = (legend=false, showaxis=false, ticks = false,
        background=:black, foreground=:white, c=palette(cs),
        title="AoC Day 13: Activation Code\n", size=(600, 175)
    )
    anim = Animation()
    for i in 1:30
        heatmap(M; options...)
        frame(anim)
        M = randomize(M)
    end
    gif(anim, "day13_anim.gif"; fps = 5)
end

