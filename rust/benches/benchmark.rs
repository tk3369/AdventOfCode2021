use criterion::{black_box, criterion_group, criterion_main, Criterion};
use aoc::day1;
use aoc::day2;
use aoc::day3;

fn criterion_benchmark(c: &mut Criterion) {
    let depths: &Vec<i32> = &day1::read_data();
    c.bench_function("Day 1 part1", |b| b.iter(|| {
        day1::part1(black_box(depths));
    }));
    c.bench_function("Day 1 part2", |b| b.iter(|| {
        day1::part2(black_box(depths));
    }));

    let input2 = &day2::read_data();
    c.bench_function("Day 2 part1", |b| b.iter(|| {
        day2::part1(black_box(input2));
    }));
    c.bench_function("Day 2 part2", |b| b.iter(|| {
        day2::part2(black_box(input2));
    }));

    let input3 = &day3::read_data();
    c.bench_function("Day 3 part1", |b| b.iter(|| {
        day3::part1(black_box(input3));
    }));
    c.bench_function("Day 3 part2", |b| b.iter(|| {
        day3::part2(black_box(input3));
    }));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);