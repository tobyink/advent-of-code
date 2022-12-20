#!perl

use v5.24;
use utf8;
use warnings;
use constant {
	FILENAME    => $ENV{ADVENT_INPUT},
	ENTRANCE    => [ 500, 0 ],
};

use Grid;
use Square;

binmode( STDOUT, ':utf8' );

say Grid->load( filename => FILENAME )->render, "\n\n";

PART_1: {
	my $g = Grid->load( filename => FILENAME );
	for my $i ( 1 .. 20_000 ) { # avoid infinite loop
		my $result = $g->drop_sand( ENTRANCE );
		# say Grid::render_sand_drop( $result, "Sand block $i" );
		if ( $result->[2] ) {
			say $g->render;
			say "Started falling into the void at ", $i;
			say "PART1: ", $i - 1;
			last;
		}
	}
	say "";
}

PART_2: {
	my $g = Grid->load( filename => FILENAME );
	$g->draw_floor( +2 );
	for my $i ( 1 .. 200_000 ) { # avoid infinite loop
		my $result = $g->drop_sand( ENTRANCE );
		# say Grid::render_sand_drop( $result, "Sand block $i" );
		if ( $result->[0] == ENTRANCE->[0] and $result->[1] == ENTRANCE->[1] ) {
			say $g->render;
			say "Entrance blocked at ", $i;
			say "PART2: ", $i;
			last;
		}
	}
	say "";
}
