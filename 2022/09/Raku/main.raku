#!/usr/bin/raku

class Knot {
	has Int $.row is rw;
	has Int $.col is rw;
	has %.history is rw;

	submethod TWEAK { self.track-history }
	method track-history () { ++%.history{ join q[,], $.row, $.col } }
	method history-size ()  { return +%.history }

	method move ( $direction ) {
		--$.row if $direction ~~ /U/;
		++$.row if $direction ~~ /D/;
		--$.col if $direction ~~ /L/;
		++$.col if $direction ~~ /R/;
		self.track-history;
	}

	method follow ( $other ) {
		return
			if abs( $.row - $other.row ) <= 1
			&& abs( $.col - $other.col ) <= 1;
		my $direction = '';
		$direction ~= 'U' if $.row > $other.row;
		$direction ~= 'D' if $.row < $other.row;
		$direction ~= 'L' if $.col > $other.col;
		$direction ~= 'R' if $.col < $other.col;
		self.move( $direction );
	}
}

sub main ( $filename, $knot_count = 2, $desc = 'ANSWER' ) {
	$knot_count > 1 or die;
	my @knot = ( 1 .. $knot_count ).map( { Knot.new( row => 0, col => 0 ) } );
	my $fh = open $filename, :r;
	for $fh.lines -> $line {
		my ( $direction, $move_count ) = split( ' ', $line );
		for 1 .. $move_count {
			@knot[0].move( $direction );
			@knot[$_].follow( @knot[$_-1] ) for 1 .. $knot_count-1;
		}
	}
	say "$desc: ", @knot[*-1].history-size;
}

main( %*ENV{'ADVENT_INPUT'},  2, 'PART1' );
main( %*ENV{'ADVENT_INPUT'}, 10, 'PART2' );
