use v5.24;
use warnings;

use constant DEBUG => 0;
use constant FILENAME => $ENV{ADVENT_INPUT};

use ItemTest;
use ItemTest::Divisible;
use Monkey;
use Operation;
use Situation;
use StolenItem;

PART_1: {
	my $s = Situation::->new_from_filename( FILENAME );
	$s->run_round for 1 .. 20;
	my @active = sort { $b <=> $a } map $_->inspection_count, $s->all_monkeys;
	say "PART1: ", $active[0] * $active[1];
}

PART_2: {
	my $s = Situation::->new_from_filename( FILENAME );
	$s->serenity_never;
	$s->run_round for 1 .. 10_000;
	my @active = sort { $b <=> $a } map $_->inspection_count, $s->all_monkeys;
	say "PART2: ", $active[0] * $active[1];
}
