use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader};

static INPUT: &str = env!("ADVENT_INPUT");

pub fn main() {
    let file = File::open( INPUT ).unwrap();
    let io = BufReader::new(file);

    // This could probably be made a lot more concise...
    let mut elf_no: i32 = 0;
    let mut calories = HashMap::<i32, isize>::new();
    for line in io.lines() {
        match line {
            Ok(line) => match &line[..] {
                "" => elf_no += 1,
                n => {
                    let i = n.parse::<isize>().unwrap();
                    match calories.get(&elf_no) {
                        Some(j) => calories.insert(elf_no, i + j),
                        None => calories.insert(elf_no, i),
                    };
                }
            },
            Err(_) => panic!("bad line read"),
        }
    }

    let mut sorted: Vec<(i32, isize)> = calories
        .keys()
        .map(|k| (*k, calories[k]))
        .collect::<Vec<(i32, isize)>>();
    sorted.sort_by_key(|i| i.1);
    sorted.reverse();

    println!("PART1: {}", sorted[0].1);

    let mut total: isize = 0;
    for n in 0..=2 {
        total += sorted[n].1;
    }
    println!("PART2: {}", total);
}
