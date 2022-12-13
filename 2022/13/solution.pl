#!perl
use v5.16;
use warnings;

sub my_cmp {
	my ( $x, $y ) = @_;
	return $y <=> $x          if ( !ref $x and !ref $y );
	return my_cmp( [$x], $y ) if ( !ref $x and  ref $y );
	return my_cmp( $x, [$y] ) if (  ref $x and !ref $y );
	my $i = 0;
	while () {
		return  0 if ( $i > $#$x and $i > $#$y );
		return  1 if ( $i > $#$x );
		return -1 if ( $i > $#$y );
		my $cmp = my_cmp( $x->[$i], $y->[$i] );
		return $cmp if $cmp;
		++$i;
	}
}

my $filename = 'input.txt';

PART_1: {
	my ( $i, $total ) = ( 0, 0 );
	open( my $fh, '<', $filename );
	while ( ++$i and not eof $fh ) {
		my $first  = eval( scalar <$fh> );
		my $second = eval( scalar <$fh> );
		my $blank  = scalar <$fh>;
		$total += $i unless my_cmp( $first, $second ) < 0;
	}
	say "Index total: $total";
}

PART_2: {
	open( my $fh, '<', $filename );
	my @all = map { chomp; length($_) ? eval($_) : () } <$fh>;
	my @markers = ( [[2]], [[6]] );
	push @all, @markers;
	my @sorted = sort { my_cmp($b, $a) } @all;
	my @indices = grep {
		$sorted[$_-1]==$markers[0] or $sorted[$_-1]==$markers[1]
	} 1 .. @sorted;
	say "Decoder key: ", $indices[0] * $indices[1];
}
