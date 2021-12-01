data() = parse.(Int, readlines("day01.txt"))
depth = data()

function part1(depths)
    return count(x -> x > 0, diff(depths))
end
# ans: 1292

function part2(depths)
    sums = [sum(depths[i:i+2]) for i in 1:length(depths)-2]
    return count(x -> x > 0, diff(sums))
end
# ans: 1262

using Plots

function overlay_chart()
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

function scatter_chart()
    depths = data()
    diff1 = diff(depths)
    diff3 = diff([sum(depths[i:i+2]) for i in 1:length(depths)-2])
    scatter(diff1, diff3,
        title = "Advent of Code - Day 1",
        xlabel = "diffs(1)",
        ylabel = "diffs(3)",
        legend = false)
end

# This solution uses the fact that the sliding window comparison is
# really just comparing the first and the 4th element:
#     a1 + a2 + a3 < a2 + a3 + a4?
# which is equivalent to answering a1 < a4
function part2_jling(depths)  # 169ns
    count(3:lastindex(depths)-1) do idx
        @inbounds depths[idx-2] < depths[idx+1]
    end
end

function part2_revised(depths) # 169ns
    return count(@inbounds depths[i] < depths[i+3] 
        for i in 1:lastindex(depths)-3)
end
