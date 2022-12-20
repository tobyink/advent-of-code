#!/usr/bin/raku

class Range {
	has Int $.start;
	has Int $.end;
	method parse ( Str $str --> Range ) {
		my ( $s, $e ) = $str.split( "-" );
		self.new( start => +$s, end => +$e );
	}
	method contains ( $self: Range $other --> Bool ) {
		$!start <= $other.start && $!end >= $other.end;
	}
	method contains-bidi ( $self: Range $other --> Bool ) {
		$self.contains( $other ) || $other.contains( $self );
	}
	method overlapping ( $self: Range $other --> Bool ) {
		( $!start >= $other.start && $!start <= $other.end )
			|| ( $!end >= $other.start && $!end <= $other.end )
			|| $self.contains-bidi( $other );
	}
}

class RangePair {
	has Range $.elf1;
	has Range $.elf2;
	method parse ( Str $str --> RangePair ) {
		my ( $r1, $r2 ) = $str.split( "," ).map( { Range.parse($_) } );
		self.new( elf1 => $r1, elf2 => $r2 );
	}
	method contains-bidi ( --> Bool ) {
		$!elf1.contains-bidi( $!elf2 );
	}
	method overlapping ( --> Bool ) {
		$!elf1.overlapping( $!elf2 );
	}
}

multi sub MAIN () {
	MAIN( %*ENV{'ADVENT_INPUT'} );
}

multi sub MAIN ($filename) {
	my $fh = open $filename, :r;
	my $count_contained = 0;
	my $count_overlapping = 0;
	for $fh.lines -> $line {
		my $rp = RangePair.parse( $line );
		if ( $rp.contains-bidi() ) {
			++$count_contained;
			++$count_overlapping;
		}
		elsif ( $rp.overlapping() ) {
			++$count_overlapping;
		}
	}
	printf( "PART1: %d\n", $count_contained );
	printf( "PART2: %d\n", $count_overlapping );
}
