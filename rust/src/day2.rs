const CONTENT: &str = include_str!("../input/day02.txt");

pub struct Command {
    cmd: String,
    steps: i32,
}

impl Command {
    fn build(str: &str) -> Command {
        let mut values = str.split(" ");
        return Command {
            cmd: String::from(values.next().unwrap()),
            steps: values.next().unwrap().parse().unwrap()
        };
    }
}

pub fn read_data() -> Vec<Command> {
    return CONTENT
        .split('\n')
        .map(|x| Command::build(x))
        .collect();
}

pub fn part1(commands: &Vec<Command>) -> i32 {
    let mut pos = 0;
    let mut depth = 0;
    for command in commands {
        let c: &str = &command.cmd;
        match c {
            "forward" => pos += command.steps,
            "up" => depth -= command.steps,
            "down" => depth += command.steps,
            bad => panic!("Bad command dude! {}", bad),
        }
    }
    return pos * depth;
}

pub fn part2(commands: &Vec<Command>) -> i32 {
    let mut pos = 0;
    let mut depth = 0;
    let mut aim = 0;
    for command in commands {
        let c: &str = &command.cmd;
        match c {
            "forward" => {
                pos += command.steps;
                depth += aim * command.steps;
            },
            "up" => aim -= command.steps,
            "down" => aim += command.steps,
            bad => panic!("Bad command dude! {}", bad),
        }
    }
    return pos * depth;
}

// Learning from other sample solutions:
//
// https://github.com/Crazytieguy/advent-2021/blob/master/src/bin/day2/main.rs
// - use tagged union for `Command`
// - defines `impl From<&str> for Command` for parsing from string
// - use lines() instead of splitting by newline
// - use collect_tuple() then destructure into multiple variables
// - has unit test
//
// https://github.com/pk-nb/advent-of-code-2021/blob/main/day2/src/main.rs
// - defines `impl std::str::FromStr for Direction` which returns `Result`
//
// https://github.com/timvisee/advent-of-code-2021/blob/master/day02a/src/main.rs
// - very concise solution
// - uses fold() to iterate and carry over state
// - tuple matching! very cool!
// - uses unreachable!() for unmatched case