#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use List::Util qw( any none );
use constant {

#	FILENAME            => 'input-test.txt',
#	PART_ONE_Y          => 10,
#	PART_ONE_SANE_RANGE => [ -100 .. 100 ],
#	PART_TWO_LBOUND     => 0,
#	PART_TWO_UBOUND     => 20,

	FILENAME            => 'input.txt',
	PART_ONE_Y          => 2_000_000,
	PART_ONE_SANE_RANGE => [ -2_000_000 .. 6_000_000 ],
	PART_TWO_LBOUND     => 0,
	PART_TWO_UBOUND     => 4_000_000,
};

package Point {
	use Moo;
	use experimental qw( signatures );

	has [ 'x', 'y' ] => ( is => 'ro' );

	sub manhattan_distance ( $self, $other ) {
		abs( $self->x - $other->x ) + abs( $self->y - $other->y )
	}

	sub is_at ( $self, $other ) {
		$self->x == $other->x and $self->y == $other->y
	}
}

package Beacon {
	use Moo;
	use experimental qw( signatures );

	extends 'Point';
}

package Sensor {
	use Moo;
	use experimental qw( signatures );

	extends 'Point';

	has closest_beacon => ( is => 'ro' );
	has beacon_distance => ( is => 'rwp' );

	sub BUILD ( $self, $arg ) {
		my $d = $self->manhattan_distance( $arg->{closest_beacon} );
		$self->_set_beacon_distance( $d );
	}

	sub within_beacon_distance ( $self, $other ) {
		$self->manhattan_distance( $other ) <= $self->beacon_distance
	}

	sub border_points ( $self ) {
		my $d = $self->beacon_distance + 1;
		my ( $self_x, $self_y ) = ( $self->x, $self->y );
		map {
			my $step = $_;
			Point::->new( x => $self_x + $step, y => $self_y + $step - $d ), # top right border point
			Point::->new( x => $self_x + $d - $step, y => $self_y + $step ), # bottom right border point
			Point::->new( x => $self_x - $step, y => $self_y + $d - $step ), # bottom left border point
			Point::->new( x => $self_x + $step - $d, y => $self_y - $step ), # top left border point
		} 1 .. $d;
	}

	sub list_from_file ( $class, $filename ) {
		open my $fh, '<', $filename or die;
		map {
			/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/;
			$class->new(
				x => $1,
				y => $2,
				closest_beacon => Beacon::->new( x => $3, y => $4 ),
			);
		} <$fh>;
	}

	sub extract_beacons ( @sensors ) {
		my %uniq;
		for my $s ( @sensors ) {
			my $b = $s->closest_beacon;
			$uniq{ join( ';', $b->x, $b->y ) } = $b;
		}
		return values %uniq;
	}
}

PART_1: {
	my @sensors = Sensor::->list_from_file( FILENAME );
	my @beacons = Sensor::extract_beacons( @sensors );

	my $y = PART_ONE_Y;
	my $count;
	for my $x ( PART_ONE_SANE_RANGE->@* ) {
		my $position = bless { x => $x, y => $y }, 'Point';
		++$count if any { $_->within_beacon_distance( $position ) } @sensors;
		--$count if any { $_->is_at( $position ) } @beacons;
	}

	say "Positions that cannot contain a beacon on y=$y: $count";
}

PART_2: {
	my @sensors = Sensor::->list_from_file( FILENAME );
	my @beacons = Sensor::extract_beacons( @sensors );

	my $found;
	SENSOR: for my $s ( @sensors ) {
		last SENSOR if $found;

		POINT: for my $position ( $s->border_points ) {
			last POINT if $found;

			next POINT if $position->x < PART_TWO_LBOUND;
			next POINT if $position->y < PART_TWO_LBOUND;
			next POINT if $position->x > PART_TWO_UBOUND;
			next POINT if $position->y > PART_TWO_UBOUND;

			$found = $position
				if none { $_->within_beacon_distance( $position ) } @sensors;
		}
	}

	say "Tuning frequency: ", ( $found->x * 4_000_000 ) + $found->y;
}
