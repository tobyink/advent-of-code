#!perl
use v5.24;
use warnings;
use constant FILENAME => $ENV{ADVENT_INPUT};

use Math::SNAFU -all;

sub part1 {
	local @ARGV = FILENAME;
	my $sum;
	while ( <> ) {
		chomp;
		$sum += snafu_to_decimal( $_ );
	}
	say "PART1: ", decimal_to_snafu( $sum );
}

unless ( caller ) {
	part1();
	# part2();
}
