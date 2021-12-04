use std::env;
use aoc::day1;
use aoc::day2;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() <= 1 {
        println!("Error: please specify a day.");
        return;
    }

    let day: &str = &args[1];
    match day {
        "1"=> {
            let depths = day1::read_data();
            println!("Part1 = {}", day1::part1(&depths));
            println!("Part2 = {}", day1::part2(&depths));
        },
        "2"=> {
            let commands = day2::read_data();
            println!("Part1 = {}", day2::part1(&commands));
            println!("Part2 = {}", day2::part2(&commands));
        },
        _ => {
            println!("Unknown day: {}", day);
        }
    }
}
