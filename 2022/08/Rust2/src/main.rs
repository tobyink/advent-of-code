use self::Direction::*;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::slice::Iter;

static INPUT: &str = env!("ADVENT_INPUT");

type Position = (usize, usize);

#[derive(Clone, Copy)]
enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    pub fn iterator() -> Iter<'static, Direction> {
        static DIRECTIONS: [Direction; 4] = [North, South, East, West];
        DIRECTIONS.iter()
    }
}

struct TreeGrid {
    trees: Vec<Vec<i32>>,
    height: usize,
    width: usize,
}

type TreeSlice = Vec<i32>;

impl TreeGrid {
    pub fn read_from_file(filename: &str) -> Self {
        let file = File::open(filename).unwrap();
        let io = BufReader::new(file);
        let trees: Vec<Vec<i32>> = io
            .lines()
            .map(|l| {
                l.unwrap()
                    .chars()
                    .map(|c| c.to_digit(10).unwrap() as i32)
                    .collect()
            })
            .collect();
        let height = trees.len();
        let width = trees[0].len();
        Self {
            trees,
            height,
            width,
        }
    }

    pub fn all_positions(&self) -> Vec<Position> {
        (0..self.height)
            .flat_map(|y| (0..self.width).map(|x| (y, x)).collect::<Vec<Position>>())
            .collect()
    }

    pub fn tree_at(&self, p: Position) -> i32 {
        self.trees[p.0][p.1]
    }

    pub fn tree_slice(&self, p: Position, d: Direction) -> TreeSlice {
        (match d {
            North if p.0 > 0 => (0..p.0).rev().map(|y| (y, p.1)).collect(),
            South if p.0 < self.height - 1 => (p.0 + 1..self.height).map(|y| (y, p.1)).collect(),
            West if p.1 > 0 => (0..p.1).rev().map(|x| (p.0, x)).collect(),
            East if p.1 < self.width - 1 => (p.1 + 1..self.width).map(|x| (p.0, x)).collect(),
            _ => Vec::new(),
        })
        .iter()
        .map(|t| self.trees[t.0][t.1])
        .collect()
    }

    pub fn tree_visible_at(&self, p: Position) -> bool {
        let tree = self.tree_at(p);
        for d in Direction::iterator() {
            match self.tree_slice(p, *d).iter().max() {
                None => return true,
                Some(shorty) if shorty < &tree => return true,
                _ => (),
            }
        }
        false
    }

    pub fn visible_count(&self) -> usize {
        self.all_positions()
            .into_iter()
            .filter(|p| self.tree_visible_at(*p))
            .count()
    }

    pub fn scenic_score_at(&self, p: Position) -> i32 {
        let tree = self.tree_at(p);
        let mut score = 1i32;
        for d in Direction::iterator() {
            let mut trees_visible_in_this_direction = 0;
            for other_tree in self.tree_slice(p, *d) {
                trees_visible_in_this_direction += 1;
                if other_tree >= tree {
                    break;
                }
            }
            if trees_visible_in_this_direction == 0 {
                return 0;
            }
            score *= trees_visible_in_this_direction;
        }
        score
    }

    pub fn max_scenic_score(&self) -> i32 {
        self.all_positions()
            .into_iter()
            .map(|p| self.scenic_score_at(p))
            .max()
            .unwrap()
    }
}

pub fn main() {
    let grid = TreeGrid::read_from_file(INPUT);
    println!("PART1: {}", grid.visible_count());
    println!("PART2: {}", grid.max_scenic_score());
}
