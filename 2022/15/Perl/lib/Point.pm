package Point;

use Moo;
use experimental qw( signatures );

has [ 'x', 'y' ] => ( is => 'ro' );

sub manhattan_distance ( $self, $other ) {
	abs( $self->x - $other->x ) + abs( $self->y - $other->y )
}

sub is_at ( $self, $other ) {
	$self->x == $other->x and $self->y == $other->y
}

1;
