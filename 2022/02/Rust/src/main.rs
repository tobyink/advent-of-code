use std::fs::File;
use std::io::{BufRead, BufReader};

static INPUT: &str = env!("ADVENT_INPUT");

#[derive(Eq, PartialEq, Debug, Clone, Copy)]
enum Shape {
    Rock,
    Paper,
    Scissors,
}

impl Shape {
    pub fn shape_score(&self) -> usize {
        match self {
            Self::Rock => 1,
            Self::Paper => 2,
            Self::Scissors => 3,
        }
    }

    pub fn is_beaten_by(&self) -> Self {
        match self {
            Self::Rock => Self::Paper,
            Self::Paper => Self::Scissors,
            Self::Scissors => Self::Rock,
        }
    }

    pub fn beats(&self) -> Self {
        match self {
            Self::Paper => Self::Rock,
            Self::Scissors => Self::Paper,
            Self::Rock => Self::Scissors,
        }
    }
}

#[derive(Eq, PartialEq, Debug, Clone, Copy)]
enum Winner {
    First,
    Second,
    Draw,
}

impl Winner {
    pub fn pick(first: Shape, second: Shape) -> Self {
        if first.beats() == second {
            Self::First
        } else if second.beats() == first {
            Self::Second
        } else {
            Self::Draw
        }
    }
}

struct Move {
    them: char,
    us: char,
}

impl Move {
    pub fn parse(line: &str) -> Self {
        Self {
            them: line.chars().nth(0).unwrap(),
            us: line.chars().nth(2).unwrap(),
        }
    }
}

fn calc_our_score_1(m: &Move) -> usize {
    let their_shape = match m.them {
        'A' => Shape::Rock,
        'B' => Shape::Paper,
        'C' => Shape::Scissors,
        _ => panic!("huh?"),
    };
    let our_shape = match m.us {
        'X' => Shape::Rock,
        'Y' => Shape::Paper,
        'Z' => Shape::Scissors,
        _ => panic!("huh?"),
    };
    let result = Winner::pick(their_shape, our_shape);
    let result_score: usize = match result {
        Winner::First => 0,
        Winner::Draw => 3,
        Winner::Second => 6,
    };
    let shape_score = our_shape.shape_score();
    result_score + shape_score
}

fn calc_our_score_2(m: &Move) -> usize {
    let their_shape = match m.them {
        'A' => Shape::Rock,
        'B' => Shape::Paper,
        'C' => Shape::Scissors,
        _ => panic!("huh?"),
    };
    let our_shape = match m.us {
        'X' => their_shape.beats(),
        'Y' => their_shape,
        'Z' => their_shape.is_beaten_by(),
        _ => panic!("huh?"),
    };
    let result = Winner::pick(their_shape, our_shape);
    let result_score: usize = match result {
        Winner::First => 0,
        Winner::Draw => 3,
        Winner::Second => 6,
    };
    let shape_score = our_shape.shape_score();
    result_score + shape_score
}

pub fn main() {
    let file = File::open(INPUT).unwrap();
    let io = BufReader::new(file);
    let mut total_score_1: usize = 0;
    let mut total_score_2: usize = 0;
    for line in io.lines() {
        let m = Move::parse(&line.unwrap());
        total_score_1 += calc_our_score_1(&m);
        total_score_2 += calc_our_score_2(&m);
    }
    println!("PART1: {}", total_score_1);
    println!("PART2: {}", total_score_2);
}
