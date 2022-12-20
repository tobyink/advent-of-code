use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader};

static INPUT: &str = env!("ADVENT_INPUT");

type MoveHistory = HashMap<(i32, i32), usize>;

#[derive(Clone)]
struct Knot {
    row: i32,
    col: i32,
    history: MoveHistory,
}

impl Knot {
    pub fn new(row: i32, col: i32) -> Self {
        let history: MoveHistory = HashMap::new();
        let mut new = Self { row, col, history };
        new.track_history();
        new
    }

    pub fn track_history(&mut self) {
        let key = (self.row, self.col);
        *self.history.entry(key).or_insert(0) += 1;
    }

    pub fn history_size(&self) -> usize {
        self.history.len()
    }

    pub fn budge(&mut self, direction: &str) {
        if direction.contains("U") {
            self.row -= 1;
        }
        if direction.contains("D") {
            self.row += 1;
        }
        if direction.contains("L") {
            self.col -= 1;
        }
        if direction.contains("R") {
            self.col += 1;
        }
        self.track_history();
    }

    pub fn follow(&mut self, other: &Self) {
        if (self.row - other.row).abs() <= 1 && (self.col - other.col).abs() <= 1 {
            return;
        }
        let mut direction = String::new();
        if self.row > other.row {
            direction.push_str("U");
        }
        if self.row < other.row {
            direction.push_str("D");
        }
        if self.col > other.col {
            direction.push_str("L");
        }
        if self.col < other.col {
            direction.push_str("R");
        }
        self.budge(&direction);
    }
}

pub fn solve(filename: &str, knot_count: usize, desc: &str) {
    if knot_count < 1 {
        panic!("knot_count too low");
    }
    let mut knots: Vec<Knot> = (1..=knot_count).map(|_| Knot::new(0, 0)).collect();

    let file = File::open(filename).unwrap();
    let io = BufReader::new(file);
    for line in io.lines() {
        let text = line.unwrap();
        let parts: Vec<&str> = text.split(" ").collect();
        let direction = parts[0];
        let move_count = parts[1].parse().unwrap();
        for _ in 0..move_count {
            knots[0].budge(direction);
            for j in 1..knot_count {
                let x = knots[j - 1].clone();
                knots[j].follow(&x);
            }
        }
    }
    println!("{}: {}", desc, knots[knot_count - 1].history_size());
}

pub fn main() {
    solve(INPUT, 2, "PART1");
    solve(INPUT, 10, "PART2");
}
