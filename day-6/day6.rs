use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    println!("Start of packet:  {}", find_marker(&input, 4));
    println!("Start of message: {}", find_marker(&input, 14));
}

fn find_marker(buffer: &str, marker_size: usize) -> usize {
    for pos in marker_size..=buffer.len() {
        let mut chars: HashMap<char,usize> = HashMap::new();
        for c in buffer[pos-marker_size..pos].chars() {
            chars.insert(c, 0);
        }
        if chars.len() == marker_size {
            return pos;
        }
    }
    0
}
