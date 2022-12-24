use v5.24;
use warnings;

package State;

use Moo;
use Types::Common -types;
use List::UtilsBy qw( uniq_by );
use experimental qw( signatures );

has valley    => ( is => 'ro', isa => Object, required => !!1 );
has parent    => ( is => 'ro', isa => Object, predicate => !!1 );
has minute    => ( is => 'ro', isa => PositiveOrZeroInt );
has row       => ( is => 'ro', isa => PositiveOrZeroInt );
has col       => ( is => 'ro', isa => PositiveOrZeroInt );

sub as_string ( $self ) {
	sprintf( 'q[%d:%d,%d]', $self->minute, $self->row, $self->col );
}

sub _maybe_safe_state ( $self, $minute, $row, $col ) {
	my $map = $self->valley->map_for_minute( $minute );
	return if $row < 0;
	return if $col < 0;
	return if $row >= $self->valley->height;
	return if $col >= $self->valley->width;
	return unless $map->has_empty_square( $row, $col );
	return ref($self)->new(
		valley => $self->valley,
		parent => $self,
		minute => $minute,
		row    => $row,
		col    => $col,
	);
}

sub next_states ( $self ) {
	my @states;

	if ( $self->row == $self->valley->height - 1
	and  $self->col == $self->valley->width - 1 ) {
		# We are in the extreme south east of the valley.
		# The end state is possible!!!
		require State::End;
		push @states, 'State::End'->new(
			valley => $self->valley,
			parent => $self,
			minute => $self->minute + 1,
		);
	}

	if ( $self->row == 0
	and  $self->col == 0 ) {
		# We are in the extreme north west of the valley.
		# The start state is possible!!!
		require State::Start;
		push @states, 'State::Start'->new(
			valley => $self->valley,
			parent => $self,
			minute => $self->minute + 1,
		);
	}

	# Depending on the openings on the map, there are up to five possible
	# states that can be returned:

	# 1. State where we move right.
	push @states, $self->_maybe_safe_state(
		$self->minute + 1,
		$self->row,
		$self->col + 1,
	);

	# 2. State where we move down.
	push @states, $self->_maybe_safe_state(
		$self->minute + 1,
		$self->row + 1,
		$self->col,
	);

	# 3. State where we don't move.
	push @states, $self->_maybe_safe_state(
		$self->minute + 1,
		$self->row,
		$self->col,
	);

	# 4. State where we move up.
	push @states, $self->_maybe_safe_state(
		$self->minute + 1,
		$self->row - 1,
		$self->col,
	);

	# 5. State where we move left.
	push @states, $self->_maybe_safe_state(
		$self->minute + 1,
		$self->row,
		$self->col - 1,
	);

	return @states;
}

sub draw ( $self ) {
	my $map = $self->valley->map_for_minute( $self->minute );
	return $map->draw( [ $self->row, $self->col ] );
}

sub find_path_until ( $self, $callback ) {
	my @states = ( $self );
	my $minutes = 0;
	while ( @states ) {
		@states = uniq_by { $_->as_string } map $_->next_states, @states;
		++$minutes;
		my @ends = grep $callback->( $_ ), @states;
		return $ends[0] if @ends;
	}
	die "Ran out of states?!";
}

1;
