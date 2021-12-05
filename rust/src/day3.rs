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
