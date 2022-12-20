use std::fs;
use std::collections::HashMap;

static INPUT: &str = env!("ADVENT_INPUT");

fn main() {
    let input = fs::read_to_string(INPUT).unwrap();
    println!("PART1: {}", find_marker(&input, 4).unwrap());
    println!("PART2: {}", find_marker(&input, 14).unwrap());
}

fn find_marker(buffer: &str, marker_size: usize) -> Option<usize> {
    for pos in marker_size..=buffer.len() {
        let mut chars: HashMap<char,usize> = HashMap::new();
        for c in buffer[pos-marker_size..pos].chars() {
            chars.insert(c, 0);
        }
        if chars.len() == marker_size {
            return Some(pos);
        }
    }
    None
}
