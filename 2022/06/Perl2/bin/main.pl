#!perl
use strict; use warnings; use experimental qw( signatures );

sub find_marker ( $buffer, $marker_size ) {
	for my $pos ( $marker_size .. length $buffer ) {
		my %chars = map { substr( $buffer, $pos-$_, 1 ) => 1 } 1 .. $marker_size;
		return $pos if keys( %chars ) == $marker_size;
	}
	return -1;
}

my $input = do { ( @ARGV, $/ ) = $ENV{ADVENT_INPUT}; <> };
printf "PART1: %d\n", find_marker( $input, 4 );
printf "PART2: %d\n", find_marker( $input, 14 );
