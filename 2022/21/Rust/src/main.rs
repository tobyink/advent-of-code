use regex::Regex;
use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};

const FILENAME: &str = env!("ADVENT_INPUT");

const ROOT_MONKEY: &str = "root";
const HUMAN: &str = "human";

type MonkeyNumber = i128;
type MonkeyName = String;
type KnownValues = HashMap<MonkeyName, MonkeyNumber>;
type Computations = HashMap<MonkeyName, Computation>;

#[derive(Clone)]
struct Computation {
    operator: char,
    first: MonkeyName,
    second: MonkeyName,
}

impl Computation {
    pub fn compute(&self, givens: &KnownValues) -> Option<MonkeyNumber> {
        let (first, second);
        match givens.get(&self.first) {
            Some(n) => first = n,
            None => return None,
        }
        match givens.get(&self.second) {
            Some(n) => second = n,
            None => return None,
        }
        match self.operator {
            '+' => Some(first + second),
            '-' => Some(first - second),
            '*' => Some(first * second),
            '/' => Some(first / second),
            x => panic!("Unknown operator: {}!", x),
        }
    }
}

fn read_monkey_data() -> (KnownValues, Computations) {
    let mut known: KnownValues = HashMap::new();
    let mut comp: Computations = HashMap::new();

    let re_known = Regex::new(r"^(?P<monkey>.{4}): (?P<number>-?\d+)$").unwrap();
    let re_comp =
        Regex::new(r"^(?P<monkey>.{4}): (?P<first>.{4}) (?P<operator>.) (?P<second>.{4})$")
            .unwrap();

    let file = File::open(FILENAME).unwrap();
    let io = BufReader::new(file);
    for line in io.lines() {
        let line = line.unwrap();
        if let Some(caps) = re_known.captures(&line) {
            let number: MonkeyNumber = caps["number"].parse().expect("Expected number");
            known.insert(caps["monkey"].to_string(), number);
        }
        if let Some(caps) = re_comp.captures(&line) {
            let computation = Computation {
                first: caps["first"].to_string(),
                second: caps["second"].to_string(),
                operator: caps["operator"].chars().next().unwrap(),
            };
            comp.insert(caps["monkey"].to_string(), computation);
        }
    }
    (known, comp)
}

fn monkey_maths(
    target: MonkeyName,
    known: &mut KnownValues,
    comp: &mut Computations,
) -> Option<MonkeyNumber> {
    loop {
        if let Some(value) = known.get(&target) {
            return Some(*value);
        }
        let mut did_something = false;
        let compcopy = comp.clone();
        for (monkey, computation) in &compcopy {
            if let Some(r) = computation.compute(&known) {
                known.insert(monkey.to_string(), r);
                comp.remove(monkey);
                did_something = true;
            }
        }
        if !did_something {
            return None;
        }
    }
}

fn part1() -> MonkeyNumber {
    let (mut known, mut comp) = read_monkey_data();
    monkey_maths(String::from(ROOT_MONKEY), &mut known, &mut comp).unwrap()
}

fn checked_div(a: MonkeyNumber, b: MonkeyNumber) -> MonkeyNumber {
    if a.abs() % b.abs() != 0 {
        panic!("Bad division: {a} is not divisible by {b}");
    }
    a / b
}

fn monkey_mystery(
    monkey_name: MonkeyName,
    target_number: MonkeyNumber,
    known: KnownValues,
    comp: Computations,
) -> MonkeyNumber {
    if monkey_name == String::from(HUMAN) {
        return target_number;
    }

    let monkey_comp = comp.get(&monkey_name).unwrap();
    let first_branch = monkey_maths(
        monkey_comp.first.clone(),
        &mut known.clone(),
        &mut comp.clone(),
    );
    let second_branch = monkey_maths(
        monkey_comp.second.clone(),
        &mut known.clone(),
        &mut comp.clone(),
    );

    if first_branch.is_none() {
        let second = second_branch.unwrap();
        let next_target = match monkey_comp.operator {
            '+' => target_number - second,
            '-' => target_number + second,
            '*' => checked_div(target_number, second),
            '/' => target_number * second,
            x => panic!("Unknown operator: {}!", x),
        };
        return monkey_mystery(monkey_comp.first.clone(), next_target, known, comp);
    }
    if second_branch.is_none() {
        let first = first_branch.unwrap();
        let next_target = match monkey_comp.operator {
            '+' => target_number - first,
            '-' => first - target_number,
            '*' => checked_div(target_number, first),
            '/' => checked_div(first, target_number),
            x => panic!("Unknown operator: {}!", x),
        };
        return monkey_mystery(monkey_comp.second.clone(), next_target, known, comp);
    }

    panic!("Huh? There's no mystery to solve!");
}

fn part2() -> MonkeyNumber {
    let (mut known, mut comp) = read_monkey_data();
    known.remove(HUMAN);
    let root = comp.remove(ROOT_MONKEY).unwrap();
    let first_branch = monkey_maths(root.first.clone(), &mut known, &mut comp);
    let second_branch = monkey_maths(root.second.clone(), &mut known, &mut comp);
    if first_branch.is_none() {
        return monkey_mystery(root.first, second_branch.unwrap(), known, comp);
    } else {
        return monkey_mystery(root.second, first_branch.unwrap(), known, comp);
    }
}

fn main() {
    println!("PART1: {}", part1());
    println!("PART2: {}", part2());
}
