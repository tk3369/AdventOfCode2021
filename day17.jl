function read_data(filename)
    m = match(r"target area: x=([0-9-]+)\.\.([0-9-]+), y=([0-9-]+)\.\.([0-9-]+)",
        read(filename, String))
    c = parse.(Int, m.captures)
    return (x=c[1]:c[2], y=c[3]:c[4])
end

"Make one step and return the new position and new velocity."
function step(position, velocity)
    x, y = position
    vx, vy = velocity
    x += vx
    y += vy
    vx = vx > 0 ? vx - 1 : (vx < 0 ? vx + 1 : 0)
    vy -= 1
    return (; x, y), (; vx, vy)
end

"""
Try to shoot the target with the specified initial velocity.
Break out of loop if the current position is below the target area.
"""
function shoot(target, velocity)
    position = (0, 0)
    height = 0
    hit = false
    while true
        position, velocity = step(position, velocity)
        height = max(height, position.y)
        if position.x ∈ target.x && position.y ∈ target.y
            hit = true
        end
        position.y < target.y[1] && break
    end
    return hit, height, position
end

"Dumb grid search"
function part1(target, sz)
    highest = 0
    for vx = -sz:sz, vy = -sz:sz
        hit, height, _ = shoot(target, (vx, vy))
        if hit && height > highest
            highest = height
        end
    end
    return highest
end

"Dumb grid search again"
function part2(target, sz)
    count(shoot(target, (vx, vy))[1] for vx ∈ -sz:sz, vy ∈ -sz:sz)
end

#=
target = read_data("day17_sample.txt")
part1(target, 300)
part2(target, 300)

target = read_data("day17.txt")
part1(target, 300)
part2(target, 300)
=#
