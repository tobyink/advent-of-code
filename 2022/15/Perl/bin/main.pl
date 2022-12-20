#!perl
use v5.24;
use warnings;
use experimental qw( signatures );

use Beacon;
use Point;
use Sensor;
use List::Util qw( any none );

use constant {
	FILENAME         => $ENV{ADVENT_INPUT},
	PART_ONE_Y       => $ENV{ADVENT_PART_ONE_Y},
	PART_ONE_LBOUND  => $ENV{ADVENT_PART_ONE_LBOUND},
	PART_ONE_UBOUND  => $ENV{ADVENT_PART_ONE_UBOUND},
	PART_TWO_LBOUND  => $ENV{ADVENT_PART_TWO_LBOUND},
	PART_TWO_UBOUND  => $ENV{ADVENT_PART_TWO_UBOUND},
};

PART_1: {
	my @sensors = Sensor::->list_from_file( FILENAME );
	my @beacons = Sensor::extract_beacons( @sensors );

	my $y = PART_ONE_Y;
	my $count;
	for my $x ( PART_ONE_LBOUND .. PART_ONE_UBOUND ) {
		my $position = bless { x => $x, y => $y }, 'Point';
		++$count if any { $_->within_beacon_distance( $position ) } @sensors;
		--$count if any { $_->is_at( $position ) } @beacons;
	}

	say "PART1: $count";
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

	say "PART2: ", ( $found->x * 4_000_000 ) + $found->y;
}
