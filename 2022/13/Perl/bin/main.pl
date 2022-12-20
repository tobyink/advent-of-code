#!perl
use v5.16;
use List::Util qw( product );
use constant FILENAME => $ENV{ADVENT_INPUT};

sub packet_cmp ($$) {
	return $_[0] <=> $_[1] unless grep ref, @_;
	my ( $ix, $cmp, $a, $b ) = ( -1, 0, map ref ? $_ : [$_], @_ );
	while ( defined $ix++ ) {
		return $ix <= $#$a if $ix > $#$b;
		return -1          if $ix > $#$a;
		return $cmp        if $cmp = packet_cmp( $a->[$ix], $b->[$ix] );
	}
}

PART_1: {
	open my $fh, '<', FILENAME or die;
	my ( $count, $total ) = ( 0, 0 );
	while ( ++$count and not eof $fh ) {
		my ( $a, $b ) = map eval scalar <$fh>, 1 .. 3;
		$total += $count unless packet_cmp( $a, $b ) > 0;
	}
	say "PART1: $total";
}

PART_2: {
	open my $fh, '<', FILENAME or die;
	my @markers = ( [[2]], [[6]] );
	my @all = sort packet_cmp @markers, map eval, <$fh>;
	say "PART2: ", product grep {
		$all[$_-1] == $markers[0] or $all[$_-1] == $markers[1]
	} 1 .. @all;
}
