use std::fs::File;
use std::io::{BufRead, BufReader};

const INPUT: &str = env!("ADVENT_INPUT");
static LIMIT: usize = 30;

type Unit = u8;
type Space = Vec<Vec<Vec<Unit>>>;
type Position = (usize, usize, usize);

static AIR: Unit = 0x00;
static ROCK: Unit = 0x01;
static POCKET: Unit = 0x02;

/// Read a file into a Space (3D vec of Units).
pub fn read_space() -> Space {
    let mut s: Space = vec![vec![vec![AIR; LIMIT]; LIMIT]; LIMIT];

    let file = File::open(INPUT).unwrap();
    let io = BufReader::new(file);
    for line in io.lines() {
        let numbers: Vec<usize> = line
            .unwrap()
            .split(",")
            .map(|n| n.parse::<usize>().unwrap())
            .collect();
        let (x, y, z) = (numbers[0], numbers[1], numbers[2]);
        s[x][y][z] = ROCK;
    }

    s
}

/// Returns a Vec of all 3D positions within certain bounds.
///
/// Saves a couple of nested loops in other functions.
pub fn all_pos(lbound: usize, ubound: usize) -> Vec<Position> {
    let side_length = ubound - lbound;
    let mut v: Vec<Position> = Vec::with_capacity(side_length * side_length * side_length);
    for x in lbound..ubound {
        for y in lbound..ubound {
            for z in lbound..ubound {
                v.push((x, y, z));
            }
        }
    }
    v
}

/// Is a given unit within a given space adjacent to another unit with a given material.
///
/// Returns a count of how many sides it is adjacent to.
pub fn unit_adjacent_to(space: &Space, (x, y, z): Position, material: Unit) -> usize {
    let mut f = 0;
    let mut edge = 0;
    if material == AIR {
        edge = 1;
    }

    // Right face
    if x + 1 >= LIMIT {
        f += edge;
    } else if space[x + 1][y][z] == material {
        f += 1;
    }
    // Left face
    if x == 0 {
        f += edge;
    } else if space[x - 1][y][z] == material {
        f += 1;
    }
    // Upper face
    if y + 1 >= LIMIT {
        f += edge;
    } else if space[x][y + 1][z] == material {
        f += 1;
    }
    // Lower face
    if y == 0 {
        f += edge;
    } else if space[x][y - 1][z] == material {
        f += 1;
    }
    // Back face
    if z + 1 >= LIMIT {
        f += edge;
    } else if space[x][y][z + 1] == material {
        f += 1;
    }
    // Front face
    if z == 0 {
        f += edge;
    } else if space[x][y][z - 1] == material {
        f += 1;
    }
    f
}

/// Count the faces within the space which are a boundary between AIR and ROCK.
pub fn exposed_faces_of_shape(space: &Space) -> usize {
    let mut count = 0;
    for p in all_pos(0, LIMIT) {
        // I do wish Rust had an idiom for this. Yeah, could use a HashMap with
        // Tuple keys, but I do prefer a three-dimentional Vec structure.
        if space[p.0][p.1][p.2] == ROCK {
            count += unit_adjacent_to(&space, p, AIR);
        }
    }
    count
}

/// Within a Space, change any AIR units to POCKET if they have no path to the
/// outside of the Space.
pub fn fill_air_pockets(space: &mut Space) {
    // First, assume that all air not on the outside of the grid
    // is in an air pocket
    for p in all_pos(1, LIMIT - 1) {
        if space[p.0][p.1][p.2] == AIR {
            space[p.0][p.1][p.2] = POCKET;
        }
    }
    // Then any pocket units which are adjacent to air can be converted
    // back to air.
    loop {
        let mut did_something = false;
        for p in all_pos(0, LIMIT) {
            if space[p.0][p.1][p.2] == POCKET && unit_adjacent_to(&space, p, AIR) > 0 {
                space[p.0][p.1][p.2] = AIR;
                did_something = true;
            }
        }
        if !did_something {
            break;
        }
    }
}

/// Solve Part 1
pub fn part1() {
    let space = read_space();
    let count = exposed_faces_of_shape(&space);
    println!("PART1: {count}");
}

/// Solve Part 2
pub fn part2() {
    let mut space = read_space();
    fill_air_pockets(&mut space);
    let count = exposed_faces_of_shape(&space);
    println!("PART2: {count}");
}

/// Solve both parts
pub fn main() {
    part1();
    part2();
}
