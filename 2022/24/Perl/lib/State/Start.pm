use v5.24;
use warnings;

package State::Start;

use Moo;
use Types::Common -types;
use experimental qw( signatures );

use State ();

extends 'State';

has '+row'    => ( isa => Int, init_arg => undef, default => -1 );
has '+col'    => ( isa => Int, init_arg => undef, default =>  0 );

sub next_states ( $self ) {

	my $next_minute = $self->minute + 1;
	my $map = $self->valley->map_for_minute( $next_minute );
	my @states;

	# State where we enter valley.
	{
		my $row = $self->row + 1;
		my $col = $self->col;
		push @states, State::->new(
			valley => $self->valley,
			parent => $self,
			minute => $next_minute,
			row    => $row,
			col    => $col,
		) if $map->has_empty_square( $row, $col );
	}

	# State where we go nowhere.
	push @states, ref($self)->new(
		valley => $self->valley,
		parent => $self,
		minute => $next_minute,
	);

	return @states;
}

1;
