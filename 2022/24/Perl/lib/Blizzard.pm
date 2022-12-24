use v5.24;
use warnings;

package Blizzard;

use Moo;
use Types::Common -types;
use experimental qw( signatures );

has valley    => ( is => 'rw', isa => Object, weak_ref => !!1 );
has init_row  => ( is => 'ro', isa => PositiveOrZeroInt );
has init_col  => ( is => 'ro', isa => PositiveOrZeroInt );
has direction => ( is => 'ro', isa => PositiveOrZeroInt );

use constant {
	NORTH      => 1,
	EAST       => 2,
	SOUTH      => 4,
	WEST       => 8,
};

sub position_at_minute ( $self, $minute ) {
	my $row = $self->init_row;
	my $col = $self->init_col;
	my $dir = $self->direction;

	if ( $dir == NORTH ) {
		$row -= $minute;
		$row %= $self->valley->height;
	}
	elsif ( $dir == SOUTH ) {
		$row += $minute;
		$row %= $self->valley->height;
	}
	elsif ( $dir == WEST ) {
		$col -= $minute;
		$col %= $self->valley->width;
	}
	elsif ( $dir == EAST ) {
		$col += $minute;
		$col %= $self->valley->width;
	}

	return ( $row, $col );
}

1;
