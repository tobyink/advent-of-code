#!perl
use v5.16;
use List::Util qw( product );
use constant FILENAME => 'input.txt';

sub my_cmp {
	return $_[1] <=> $_[0] unless grep ref, @_;
	my ( $ix, $cmp, $a, $b ) = ( -1, 0, map ref ? $_ : [$_], @_ );
	while ( defined $ix++ ) {
		return $ix <= $#$b if $ix > $#$a;
		return -1          if $ix > $#$b;
		return $cmp        if $cmp = my_cmp( $a->[$ix], $b->[$ix] );
	}
}

PART_1: {
	open my $fh, '<', FILENAME;
	my ( $count, $total ) = ( 0, 0 );
	while ( ++$count and not eof $fh ) {
		my ( $a, $b ) = map eval scalar <$fh>, 1..3;
		$total += $count unless my_cmp( $a, $b ) < 0;
	}
	say "Index total: $total";
}

PART_2: {
	open my $fh, '<', FILENAME;
	my @markers = ( [[2]], [[6]] );
	my @all = sort { my_cmp( $b, $a ) } @markers, map eval, <$fh>;
	say "Decoder key: ", product grep {
		$all[$_-1]==$markers[0] or $all[$_-1]==$markers[1]
	} 1 .. @all;
}
