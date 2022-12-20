package Sensor;

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

1;
