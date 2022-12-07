#!perl
use strict; use warnings; use experimental qw( signatures );

sub find_marker ( $buffer, $marker_size ) {
	for my $pos ( $marker_size .. length $buffer ) {
		my %chars = map { substr( $buffer, $pos-$_, 1 ) => 1 } 1 .. $marker_size;
		return $pos if keys( %chars ) == $marker_size;
	}
	return -1;
}

my $input = do { ( @ARGV, $/ ) = 'input.txt'; <> };
printf "Start of packet:  %d\n", find_marker( $input, 4 );
printf "Start of message: %d\n", find_marker( $input, 14 );
