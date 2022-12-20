use std::fs::File;
use std::io::{BufRead, BufReader};

static INPUT: &str = env!("ADVENT_INPUT");

#[derive(Debug)]
struct Tree {
    height: i32,
    visible_from_north: bool,
    visible_from_south: bool,
    visible_from_east: bool,
    visible_from_west: bool,
    visible: bool,
    scenic_score: i32,
}

impl Tree {
    pub fn from_char(c: char) -> Self {
        Self {
            height: c.to_digit(10).unwrap() as i32,
            visible_from_north: true,
            visible_from_south: true,
            visible_from_east: true,
            visible_from_west: true,
            visible: true,
            scenic_score: 0,
        }
    }
}

#[derive(Debug)]
struct TreeGrid {
    trees: Vec<Vec<Tree>>,
    height: usize,
    width: usize,
}

impl TreeGrid {
    pub fn read_from_file(filename: &str) -> Self {
        let file = File::open(filename).unwrap();
        let io = BufReader::new(file);
        let trees: Vec<Vec<Tree>> = io
            .lines()
            .map(|l| l.unwrap().chars().map(|c| Tree::from_char(c)).collect())
            .collect();
        let height = trees.len();
        let width = trees[0].len();
        let mut grid = Self {
            trees,
            height,
            width,
        };
        grid.calculate_obscurities();
        grid.calculate_scenic_scores();
        grid
    }

    pub fn calculate_obscurities(&mut self) {
        let mut tallest_in_col: Vec<i32> = vec![-1; self.width];
        let mut tallest_in_row: Vec<i32> = vec![-1; self.height];
        for y in 0..self.height {
            for x in 0..self.width {
                let mut tree = &mut self.trees[y][x];
                if tree.height <= tallest_in_row[y] {
                    tree.visible_from_west = false;
                } else {
                    tallest_in_row[y] = tree.height;
                }
                if tree.height <= tallest_in_col[x] {
                    tree.visible_from_north = false;
                } else {
                    tallest_in_col[x] = tree.height;
                }
            }
        }

        let mut tallest_in_col: Vec<i32> = vec![-1; self.width];
        let mut tallest_in_row: Vec<i32> = vec![-1; self.height];
        for y in (0..self.height).rev() {
            for x in (0..self.width).rev() {
                let mut tree = &mut self.trees[y][x];
                if tree.height <= tallest_in_row[y] {
                    tree.visible_from_east = false;
                } else {
                    tallest_in_row[y] = tree.height;
                }
                if tree.height <= tallest_in_col[x] {
                    tree.visible_from_south = false;
                } else {
                    tallest_in_col[x] = tree.height;
                }
            }
        }

        for y in 0..self.height {
            for x in 0..self.width {
                let mut tree = &mut self.trees[y][x];
                tree.visible = tree.visible_from_east
                    || tree.visible_from_west
                    || tree.visible_from_north
                    || tree.visible_from_south;
            }
        }
    }

    pub fn visible_count(&self) -> i32 {
        let mut total = 0;
        for y in 0..self.height {
            for x in 0..self.width {
                if self.trees[y][x].visible {
                    total += 1;
                }
            }
        }
        total
    }

    pub fn calculate_scenic_scores(&mut self) {
        for y in 0..self.height {
            for x in 0..self.width {
                let treehouse_tree = &self.trees[y][x];

                let mut score_north = 0i32;
                let mut viewing = y;
                while viewing > 0 {
                    viewing -= 1;
                    let visible_tree = &self.trees[viewing][x];
                    score_north += 1;
                    if visible_tree.height >= treehouse_tree.height {
                        break;
                    }
                }

                let mut score_south = 0i32;
                let mut viewing = y;
                while viewing < self.height - 1 {
                    viewing += 1;
                    let visible_tree = &self.trees[viewing][x];
                    score_south += 1;
                    if visible_tree.height >= treehouse_tree.height {
                        break;
                    }
                }

                let mut score_west = 0i32;
                let mut viewing = x;
                while viewing > 0 {
                    viewing -= 1;
                    let visible_tree = &self.trees[y][viewing];
                    score_west += 1;
                    if visible_tree.height >= treehouse_tree.height {
                        break;
                    }
                }

                let mut score_east = 0i32;
                let mut viewing = x;
                while viewing < self.width - 1 {
                    viewing += 1;
                    let visible_tree = &self.trees[y][viewing];
                    score_east += 1;
                    if visible_tree.height >= treehouse_tree.height {
                        break;
                    }
                }

                let mut tree = &mut self.trees[y][x];
                tree.scenic_score = score_north * score_south * score_east * score_west;
            }
        }
    }

    pub fn max_scenic_score(&self) -> i32 {
        let mut max = 0;
        for y in 0..self.height {
            for x in 0..self.width {
                let treehouse_tree = &self.trees[y][x];
                if treehouse_tree.scenic_score > max {
                    max = treehouse_tree.scenic_score;
                }
            }
        }
        max
    }
}

pub fn main() {
    let grid = TreeGrid::read_from_file(INPUT);
    println!("PART1: {}", grid.visible_count());
    println!("PART2: {}", grid.max_scenic_score());
}
