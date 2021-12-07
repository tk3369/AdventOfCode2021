const CONTENT: &str = include_str!("../input/day03.txt");

pub fn read_data() -> Vec<&'static str> {
    return CONTENT.lines().collect();
}

fn most_common(input: &Vec<&str>, j: usize) -> i32 {
    let ones = input
        .iter()
        .filter(|x| get_bitchar(x, j) == '1')
        .count();
    let zeros = input.len() - ones;
    return if ones >= zeros {1} else {0};
}

fn decimal(bits: Vec<i32>) -> i32 {
    return bits.iter().fold(0, |acc, &b| acc*2 + b as i32);
}

pub fn part1(input: &Vec<&str>) -> i32 {
    let cols = input[0].len();
    let mut gamma = Vec::<i32>::new();
    let mut epsilon = Vec::<i32>::new();
    for j in 0..cols {
        let bit = most_common(input, j);
        gamma.push(bit);
        epsilon.push(flip_bit(bit));
    }
    return decimal(gamma) * decimal(epsilon);
}

fn get_bitchar(s: &str, j: usize) -> char {
    return s.as_bytes()[j] as char;
}

fn to_bitchar(bit: i32) -> char {
    return if bit == 1 {'1'} else {'0'};
}

fn to_bit(bitchar: char) -> i32 {
    return if bitchar == '1' {1} else {0};
}

fn flip_bit(bit: i32) -> i32 {
    return if bit == 1 {0} else {1};
}

fn to_bit_vec(s: &str) -> Vec<i32> {
    return s.chars().map(|x| to_bit(x)).collect();
}

// Find indices of the input where jth bit == bit
fn select(input: &Vec<&'static str>, j: usize, bit: char) -> Vec<&'static str> {
    return input
        .iter()
        .filter(|x| get_bitchar(x, j) == bit)
        .cloned()
        .collect();
}

fn find_factor(input: &Vec<&'static str>, most: bool) -> &'static str {
    let mut pos = 0;
    let mut state: Vec<&'static str> = input.to_vec();
    loop {
        let mut bit = most_common(&state, pos);
        if !most {
            bit = flip_bit(bit);
        }
        state = select(&state, pos, to_bitchar(bit));
        if state.len() == 1 {
            break;
        }
        pos += 1;
    }
    return state[0];
}

pub fn part2(input: &Vec<&'static str>) -> i32 {
    let oxygen = to_bit_vec(find_factor(input, true));
    let co2 = to_bit_vec(find_factor(input, false));
    return decimal(oxygen) * decimal(co2);
}

// Adapting from https://github.com/timvisee/advent-of-code-2021/blob/master/day03b/src/main.rs

const WIDTH: usize = 5;

pub fn part2_tim() {
    let nums = include_str!("../input/day03_sample.txt")
        .lines()
        .map(|l| u32::from_str_radix(l, 2).unwrap())
        .collect::<Vec<_>>();

    let oxy = (0..WIDTH)
        .rev()
        .scan(nums.clone(), |oxy, i| {
            let one = oxy.iter().filter(|n| *n & 1 << i > 0).count() >= (oxy.len() + 1) / 2;
            // oxy.drain_filter(|n| (*n & 1 << i > 0) != one);
            drain_filter(oxy, |n: u32| (n & 1 << i > 0) != one);
            oxy.first().copied()
        })
        .last()
        .unwrap();

    let co2 = (0..WIDTH)
        .rev()
        .scan(nums, |co2, i| {
            let one = co2.iter().filter(|n| *n & 1 << i > 0).count() >= (co2.len() + 1) / 2;
            drain_filter(co2, |n| (n & 1 << i > 0) == one);
            co2.first().copied()
        })
        .last()
        .unwrap();

    println!("{}", oxy * co2);
}

// My own iterative version of drain_filter
fn drain_filter<F: Fn(u32)->bool>(v: &mut Vec<u32>, pred: F) {
    let mut pos = 0;
    loop {
        if pred(v[pos]) {
            v.swap_remove(pos);
        } else {
            pos += 1;
        }
        if pos >= v.len() { break; }
    }
}