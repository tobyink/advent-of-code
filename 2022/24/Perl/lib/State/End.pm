use v5.24;
use warnings;

package State::End;

use Moo;
use Types::Common -types;
use experimental qw( signatures );

use State ();

extends 'State';

has '+row'    => ( is => 'rwp', init_arg => undef );
has '+col'    => ( is => 'rwp', init_arg => undef );

sub BUILD ( $self, $args ) {
	$self->_set_row( $self->valley->height );
	$self->_set_col( $self->valley->width - 1 );
}

sub next_states ( $self ) {

	my $next_minute = $self->minute + 1;
	my $map = $self->valley->map_for_minute( $next_minute );
	my @states;

	# State where we enter valley.
	{
		my $row = $self->valley->height - 1;
		my $col = $self->valley->width - 1;
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
