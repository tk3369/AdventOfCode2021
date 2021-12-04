// include_str!() embeds the content in the binary
// whereas fs::read_to_string() would read data at run time
const CONTENT: &str = include_str!("../day01.txt");

pub fn read_data() -> Vec<i32> {
    return CONTENT
        .split('\n')
        .map(|x| x.parse::<i32>().unwrap())
        .collect();
}

// #[inline] used for criterion benchmark (see benches/benchmark.rs)
#[inline]
pub fn part1_windows(depths: &Vec<i32>) -> usize {
    return depths.windows(2)
        .filter(|x| x[0] < x[1])
        .count();
}

// Notes:
// - To catch parsing errors, wrap `x` in the `dbg!` macro.

// Questions:
// - Windowing is lazy, but I wonder if it allocates...
