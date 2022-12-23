#![allow(unused,dead_code)]

use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

const FILENAME: &str = env!("ADVENT_INPUT");

const SQ_EMPTY: u32         = 0x0000;
const SQ_ELF: u32           = 0x0001;
const SQ_CONSIDERED_N: u32 = 0x0100;
const SQ_CONSIDERED_E: u32 = 0x0200;
const SQ_CONSIDERED_S: u32 = 0x0400;
const SQ_CONSIDERED_W: u32 = 0x0800;

type GridSquare = u32;
type GridLine = Vec<GridSquare>;
type Grid = Vec<GridLine>;

fn read_grid () -> Grid {
    let file = File::open(FILENAME).unwrap();
    let io = BufReader::new(file);
    io.lines().map(|line| {
        line.unwrap().chars().map(|c| {
            match c {
                '#' => SQ_ELF,
                '.' => SQ_EMPTY,
                _ => panic!("bad input"),
            }
        }).collect()
    }).collect()
}

fn elf_at (g: &Grid, r: usize, c: usize) -> bool {
    g[r][c] & SQ_ELF != 0
}

fn elf_near (g: &Grid, r: usize, c: usize) -> bool {
    let height = g.len();
    let width = g[0].len();

    if r > 0 {
        if c > 0 && elf_at(&g, r-1, c-1) {
            return true;
        }
        if elf_at(&g, r-1, c) {
            return true;
        }
        if c < width && elf_at(&g, r-1, c) {
            return true;
        }
    }

    if c > 0 && elf_at(&g, r, c-1) {
        return true;
    }
    if c < width && elf_at(&g, r, c) {
        return true;
    }

    if r < height - 1 {
        if c > 0 && elf_at(&g, r+1, c-1) {
            return true;
        }
        if elf_at(&g, r+1, c) {
            return true;
        }
        if c < width && elf_at(&g, r+1, c) {
            return true;
        }
    }

    false
}

fn consider_moves(g: &mut Grid) -> usize {
    let height = g.len();
    let width = g[0].len();
    let mut count = 0;
    for row in 0..height {
        for col in 0..width {
            if elf_at(&g, row, col) && elf_near(&g, row, col) {
                if !elf_at(&g, row-1, col-1) && !elf_at(&g, row-1, col) && !elf_at(&g, row-1, col+1) {
                    g[row-1][col] |= SQ_CONSIDERED_N;
                    count += 1;
                }
                else if !elf_at(&g, row+1, col-1) && !elf_at(&g, row+1, col) && !elf_at(&g, row+1, col+1) {
                    g[row+1][col] |= SQ_CONSIDERED_S;
                    count += 1;
                }
                else if !elf_at(&g, row-1, col-1) && !elf_at(&g, row, col-1) && !elf_at(&g, row+1, col-1) {
                    g[row+1][col] |= SQ_CONSIDERED_W;
                    count += 1;
                }
                else if !elf_at(&g, row-1, col+1) && !elf_at(&g, row, col+1) && !elf_at(&g, row+1, col+1) {
                    g[row+1][col] |= SQ_CONSIDERED_E;
                    count += 1;
                }
            }
        }
    }
    count
}

fn make_moves(g: &mut Grid) {
    let height = g.len();
    let width = g[0].len();
    for row in 0..height {
        for col in 0..width {
            let sq = g[row][col];
            // If square considered for northwards move only...
            if sq == SQ_CONSIDERED_N {
                g[row][col] = SQ_ELF;
                g[row+1][col] = SQ_EMPTY;
            }
            // If square considered for eastwards move only...
            else if sq == SQ_CONSIDERED_E {
                g[row][col] = SQ_ELF;
                g[row][col-1] = SQ_EMPTY;
            }
            // If square considered for southwards move only...
            else if sq == SQ_CONSIDERED_S {
                g[row][col] = SQ_ELF;
                g[row-1][col] = SQ_EMPTY;
            }
            // If square considered for westwards move only...
            else if sq == SQ_CONSIDERED_W {
                g[row][col] = SQ_ELF;
                g[row][col+1] = SQ_EMPTY;
            }
            // If square was considered by multiple elves...
            else if sq >= SQ_CONSIDERED_N {
                g[row][col] = SQ_EMPTY;
            }
        }
    }
}

fn grid_needs_expansion(g: &Grid) -> bool {
    let height = g.len();
    let width = g[0].len();
    for col in 0 .. width {
        if elf_at(&g, 0, col) {
            return true;
        }
        if elf_at(&g, height-1, col) {
            return true;
        }
    }
    for row in 0 .. height {
        if elf_at(&g, row, 0) {
            return true;
        }
        if elf_at(&g, row, width-1) {
            return true;
        }
    }
    false
}

fn expand_grid(g: &mut Grid) -> Grid {
    let height = g.len();
    let width = g[0].len();
    let expand_by = 8usize;

    let mut new: Grid = Vec::new();
    for i in 0 .. expand_by/2 {
        new.push(vec![SQ_EMPTY; width + expand_by]);
    }
    for row in g {
        let mut new_l: GridLine = vec![SQ_EMPTY; expand_by/2];
        let mut tail: GridLine = vec![SQ_EMPTY; expand_by/2];
        new_l.append(row);
        new_l.append(&mut tail);
        new.push(new_l);
    }
    for i in 0 .. expand_by/2 {
        new.push(vec![SQ_EMPTY; width + expand_by]);
    }
    new
}

fn shrink_grid(g: &Grid) -> Grid {
    g.clone()
}

fn count_empty(g: &Grid) -> usize {
    let mut empty = 0;
    let height = g.len();
    let width = g[0].len();
    for row in 0..height {
        for col in 0..width {
            if elf_at(&g, row, col) {
                empty += 1;
            }
        }
    }
    empty
}

fn dump_grid (g: &Grid) -> String {
    let mut s = String::new();
    for row in g {
        let cells: Vec<&str> = row.iter().map(|c| {
            match *c {
                SQ_EMPTY => ".",
                SQ_ELF => "#",
                _ => "?",
            }
        }).collect();
        s.push_str(&cells.join(""));
        s.push_str("\n");
    }
    s
}

fn part1 () {
    let mut grid = read_grid();
    let mut count = 0;
    loop {
        count += 1;
        if grid_needs_expansion(&grid) {
            println!("Expanding grid");
            grid = expand_grid(&mut grid);
        }
        let considered_moves = consider_moves(&mut grid);
        if considered_moves == 0 {
            break;
        }
        make_moves(&mut grid);
        println!("{}", dump_grid(&grid));
        if count > 4 {
            break;
        }
    }
    grid = shrink_grid(&grid);
    println!("{}", dump_grid(&grid));
    println!("PART1: {}", count_empty(&grid));
}

fn main() {
    part1();
}
