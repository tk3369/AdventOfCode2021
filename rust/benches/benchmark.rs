use criterion::{black_box, criterion_group, criterion_main, Criterion};
use aoc::day1;

fn criterion_benchmark(c: &mut Criterion) {
    let depths: &Vec<i32> = &day1::read_data();
    c.bench_function("part1", |b| b.iter(|| {
        day1::part1(black_box(depths));
    }));
    c.bench_function("part2", |b| b.iter(|| {
        day1::part2(black_box(depths));
    }));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);