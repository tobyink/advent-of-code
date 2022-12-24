use v5.24;
use warnings;

package Map;

use Moo;
use Types::Common -types;
use experimental qw( signatures );

use constant {
	EMPTY      => 0,
	BLIZZARD_N => 1,
	BLIZZARD_E => 2,
	BLIZZARD_S => 4,
	BLIZZARD_W => 8,
	WALL       => 16,
};

has valley    => ( is => 'ro', isa => Object, weak_ref => !!1 );
has grid      => ( is => 'ro', isa => ArrayRef );

sub has_empty_square ( $self, $row, $col ) {
	$self->grid->[$row][$col] == EMPTY
}

sub draw ( $self, $E = undef ) {
	my $str = '#.' . ( '#' x $self->valley->width ) . "\n";
	for my $row ( $self->grid->@* ) {
		$str .= '#';
		for my $cell ( $row->@* ) {
			$str .=
				( $cell == EMPTY )       ? '.' :
				( $cell == WALL )        ? '#' :
				( $cell == BLIZZARD_N )  ? '^' :
				( $cell == BLIZZARD_E )  ? '>' :
				( $cell == BLIZZARD_S )  ? 'v' :
				( $cell == BLIZZARD_W )  ? '<' : 'X';
		}
		$str .= "#\n";
	}
	$str .= ( '#' x $self->valley->width ) . ".#\n";

	if ( $E ) {
		my ( $e_row, $e_col ) = $E->@*;
		my @lines = split /\n/, $str;
		substr( $lines[$e_row + 1], $e_col + 1, 1 ) = 'E';
		$str = join "\n", @lines;
	}

	chomp $str;
	return $str;
}

1;
