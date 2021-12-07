use std::env;
use aoc::day1;
use aoc::day2;
use aoc::day3;
use aoc::day7;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() <= 1 {
        println!("Error: please specify a day.");
        return;
    }

    let day: &str = &args[1];
    match day {
        "1"=> {
            let input = day1::read_data();
            println!("Part1 = {}", day1::part1(&input));
            println!("Part2 = {}", day1::part2(&input));
        },
        "2"=> {
            let input = day2::read_data();
            println!("Part1 = {}", day2::part1(&input));
            println!("Part2 = {}", day2::part2(&input));
        },
        "3"=> {
            let input = day3::read_data();
            println!("Part1 = {}", day3::part1(&input));
            println!("Part2 = {}", day3::part2(&input));
        },
        "7"=> {
            let input = day7::read_data();
            println!("Part1 = {}", day7::part1(&input));
            println!("Part2 = {}", day7::part2(&input));
        },
        "play" => {
            day3::part2_tim();
        }
        _ => {
            println!("Unknown day: {}", day);
        }
    }
}
