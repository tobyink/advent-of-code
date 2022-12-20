use std::fs::File;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;

static INPUT: &str = env!("ADVENT_INPUT");

pub fn main() {
    let file = File::open(INPUT).unwrap();
    let io = BufReader::new(file);

    let mut total_score_1: usize = 0;
    let mut total_score_2: usize = 0;

    let strategy1 = HashMap::from([
        ("A X", 4),
        ("A Y", 8),
        ("A Z", 3),
        ("B X", 1),
        ("B Y", 5),
        ("B Z", 9),
        ("C X", 7),
        ("C Y", 2),
        ("C Z", 6),
    ]);
    let strategy2 = HashMap::from([
        ("A X", 3),
        ("A Y", 4),
        ("A Z", 8),
        ("B X", 1),
        ("B Y", 5),
        ("B Z", 9),
        ("C X", 2),
        ("C Y", 6),
        ("C Z", 7),
    ]);

    for line in io.lines() {
        let key = line.unwrap();
        total_score_1 += strategy1.get(&key[..]).unwrap();
        total_score_2 += strategy2.get(&key[..]).unwrap();
    }

    println!("PART1: {}", total_score_1);
    println!("PART2: {}", total_score_2);
}
