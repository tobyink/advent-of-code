#!perl
use v5.24;
use warnings;
use experimental qw( signatures );

use Knot;
use constant FILENAME => $ENV{ADVENT_INPUT};

sub main ( $filename, $knot_count = 2, $desc = 'ANSWER' ) {
	$knot_count > 1 or die;
	my @knot = map Knot->new( row => 0, col => 0 ), 1 .. $knot_count;

	local @ARGV = $filename;
	while ( <> ) {
		chomp;
		my ( $direction, $move_count ) = split / /;
		while ( $move_count-->0 ) {
			$knot[0]->move( $direction );
			$knot[$_]->follow( $knot[$_ - 1] ) for 1 .. $#knot;
		}
	}

	say "$desc: ", $knot[-1]->history_size;
}

if ( not caller ) {
	main( FILENAME, 2, "PART1" );
	main( FILENAME, 10, "PART2" );
}
