data() = parse.(Int, readlines("day01.txt"))

function part1()
    depths = data()
    return count(x -> x > 0, diff(depths))
end
# ans: 1292

function part2()
    depths = data()
    sums = [sum(depths[i:i+2]) for i in 1:length(depths)-2]
    return count(x -> x > 0, diff(sums))
end
# ans: 1262


using Plots

function overlay_graph()
    depths = data()
    diff1 = diff(depths)
    diff3 = diff([sum(depths[i:i+2]) for i in 1:length(depths)-2])

    anim = Animation()
    plot(diff1, label = "diff1", color = :blue, alpha = 0.5, 
        title = "Advent of Code: Day 1", ylim = (-70, 70))
    frame(anim)

    @animate for n in 1:30:length(diff3)
        plot!(diff3[1:n], label = "diff3", color = :orange,
            alpha = 0.5, legend = false)
        frame(anim)
    end
    gif(anim, "day01_anim.gif", fps = 15)
end
