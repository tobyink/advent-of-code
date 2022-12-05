use std::fs::File;
use std::io::{BufRead, BufReader};

#[derive(Clone)]
struct Range {
    start: usize,
    end: usize,
}

type RangePair = (Range, Range);

impl Range {
    fn parse_from_str(s: &str) -> Self {
        let parts: Vec<&str> = s.split("-").collect();
        let start = parts[0].parse::<usize>().unwrap();
        let end = parts[1].parse::<usize>().unwrap();
        Self { start, end }
    }

    fn parse_pair_from_str(s: &str) -> RangePair {
        let parts: Vec<Self> = s.split(",").map(Self::parse_from_str).collect();
        (parts[0].clone(), parts[1].clone())
    }

    fn fully_contains(&self, other: &Self) -> bool {
        self.start <= other.start && self.end >= other.end
    }

    fn bidi_fully_contains(&self, other: &Self) -> bool {
        self.fully_contains(other) || other.fully_contains(self)
    }

    fn overlaps(&self, other: &Self) -> bool {
        (self.start >= other.start && self.start <= other.end)
            || (self.end >= other.start && self.end <= other.end)
            || self.bidi_fully_contains(other)
    }
}

fn main() {
    let file = File::open("input.txt").unwrap();
    let io = BufReader::new(file);

    let pairs: Vec<RangePair> = io
        .lines()
        .map(|r| Range::parse_pair_from_str(&r.unwrap()))
        .collect();

    let fully_contained: Vec<&RangePair> = pairs
        .iter()
        .filter(|(elf1, elf2)| elf1.bidi_fully_contains(&elf2))
        .collect();
    println!("Count of fully contained pairs: {}", fully_contained.len());

    let overlapping: Vec<&RangePair> = pairs
        .iter()
        .filter(|(elf1, elf2)| elf1.overlaps(&elf2))
        .collect();
    println!("Count of overlapping pairs: {}", overlapping.len());
}
