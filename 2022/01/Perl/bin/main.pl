#!perl

use v5.14;
use warnings;
use constant FILENAME => $ENV{ADVENT_INPUT};

my @calories = do {
	local @ARGV = FILENAME;
	my ( $i, @data ) = 0;
	while ( <> ) {
		chomp;
		/[0-9]/ ? ( $data[$i] += $_ ) : ++$i;
	}
	@data;
};

my @sorted =
	sort { $b->[1] <=> $a->[1] }
	map { [ $_, $calories[$_] ] }
	0 .. $#calories;

say "PART1: ", $sorted[0][1];

my $total = 0;
$total += $sorted[$_][1] for 0..2;
say "PART2: ", $total;
