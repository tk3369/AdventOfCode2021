const CONTENT: &str = include_str!("../input/day07.txt");

pub fn read_data() -> Vec<i32> {
    return CONTENT
        .split(",")
        .map(|x| x.parse().unwrap())
        .collect();
}

// Every step equals to exactly 1 unit of fuel
fn constant_cost(x: i32, y:i32) -> i32 {
    return (x - y).abs();
}

// Every step increases fuel requirement by 1 unit
fn linear_cost(x: i32, y:i32) -> i32 {
    let steps = (x - y).abs();
    return steps * (steps + 1) / 2;
}

// Calculate fuel required for all crabs to move to the same target position
fn fuel_required(target: i32, pos: &Vec<i32>, costy: fn(i32,i32)->i32) -> i32 {
    return pos
        .iter()
        .fold(0, |acc, &p| acc + costy(p, target));
}

// Calculate minimum fuel required to move all crabs to some position
fn minimum_fuel(pos: &Vec<i32>, costy: fn(i32,i32)->i32) -> i32 {
    let n: i32 = *pos.iter().min().unwrap();
    let m: i32 = *pos.iter().max().unwrap();
    return (n..=m)
        .map(|p| fuel_required(p, pos, costy))
        .min()
        .unwrap();
}

pub fn part1(pos: &Vec<i32>) -> i32 {
    return minimum_fuel(pos, constant_cost);
}

pub fn part2(pos: &Vec<i32>) -> i32 {
    return minimum_fuel(pos, linear_cost);
}