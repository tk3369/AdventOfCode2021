use criterion::{black_box, criterion_group, criterion_main, Criterion};
use day01;

fn criterion_benchmark(c: &mut Criterion) {
    let depths: &Vec<i32> = &day01::read_data();
    c.bench_function("part1", |b| b.iter(|| {
        day01::part1_windows(black_box(depths));
    }));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);