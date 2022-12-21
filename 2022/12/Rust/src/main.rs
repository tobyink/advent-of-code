use std::fs::File;
use std::io::{BufRead, BufReader};

static INPUT: &str = env!("ADVENT_INPUT");

struct Square {
    letter: char,
    height: u32,
    distance: Option<u32>,
}

impl Square {
    pub fn new(letter: char, start_point: &Vec<char>) -> Self {
        let mut distance = None;
        let height = match letter {
            'S' => 1,
            'E' => 26,
            'a'..='z' => letter.to_digit(36).unwrap() - 9,
            _ => panic!("bad character"),
        };
        if start_point.contains(&letter) {
            distance = Some(0);
        }
        Self {
            letter,
            height,
            distance,
        }
    }
}

struct Map {
    description: String,
    grid: Vec<Vec<Square>>,
    #[allow(dead_code)]
    start_point: Vec<char>,
    end_point: Vec<char>,
}

impl Map {
    pub fn load(
        description: &str,
        filename: &str,
        start_point: Vec<char>,
        end_point: Vec<char>,
    ) -> Self {
        let description = String::from(description);

        let file = File::open(filename).unwrap();
        let io = BufReader::new(file);
        let grid: Vec<Vec<Square>> = io
            .lines()
            .map(|l| {
                l.unwrap()
                    .chars()
                    .map(|c| Square::new(c, &start_point))
                    .collect()
            })
            .collect();

        Self {
            description,
            grid,
            start_point,
            end_point,
        }
    }

    pub fn lookup_square(&self, row: i32, col: i32) -> Option<&Square> {
        if row < 0 || col < 0 {
            return None;
        }
        let row = row as usize;
        let col = col as usize;
        if row >= self.grid.len() {
            return None;
        }
        if col >= self.grid[row].len() {
            return None;
        }
        Some(&self.grid[row][col])
    }

    pub fn run_simulation(&mut self) {
        let mut step = 0u32;
        'step: loop {
            step += 1;
            let mut actions = 0;
            for row in 0..self.grid.len() {
                let row_i32 = row as i32;
                'sq: for col in 0..self.grid[row].len() {
                    let col_i32 = col as i32;
                    let square = self.lookup_square(row_i32, col_i32).unwrap();
                    if square.distance.is_some() {
                        continue 'sq;
                    }

                    // Find neighbours (n) directly up, right, down, and left of square,
                    // but filter based on whether it exists, has a distance set on a
                    // previous iteration of the outer loop (not this iteration!), and
                    // isn't too tall.
                    let neighbours: Vec<&Square> = [
                        (row_i32 - 1, col_i32),
                        (row_i32, col_i32 + 1),
                        (row_i32 + 1, col_i32),
                        (row_i32, col_i32 - 1),
                    ]
                    .iter()
                    .filter_map(|(r, c)| self.lookup_square(*r, *c))
                    .filter(|n| n.distance.is_some() && n.distance < Some(step))
                    .filter(|n| square.height <= n.height + 1)
                    .collect();

                    if neighbours.len() > 0 {
                        actions += neighbours.len();
                        // Can't use `square` here because it isn't mut
                        self.grid[row][col].distance = Some(step);
                    }

                    // Need to shadow old `square` variable because it mutated.
                    let square = self.lookup_square(row_i32, col_i32).unwrap();
                    if square.distance.is_some() && self.end_point.contains(&square.letter) {
                        println!("{}: {}", self.description, step);
                        break 'step;
                    }
                }
            }

            if step > 5000 || actions == 0 {
                println!("Deadlock?!");
                break 'step;
            }
        }
    }
}

pub fn main() {
    Map::load("PART1", INPUT, vec!['S'], vec!['E']).run_simulation();
    Map::load("PART2", INPUT, vec!['S', 'a'], vec!['E']).run_simulation();
}
