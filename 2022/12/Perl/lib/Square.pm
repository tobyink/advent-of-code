use v5.24;

package Square;

use Moo;
use experimental qw( signatures );

has letter      => ( is => 'ro', required => !!1 );
has height      => ( is => 'rwp' );
has distance    => ( is => 'ro', writer => 'set_distance' );

sub has_distance ( $self ) {
	defined( $self->distance );
}

sub marker ( $self ) {
	defined( $self->distance ) ? $self->letter : '.';
}

my %H = do {
	my $i = 0;
	map +( $_ => ++$i ), 'a' .. 'z';
};
$H{'S'} = $H{'a'};
$H{'E'} = $H{'z'};
sub BUILD ( $self, $args ) {
	my $letter = $args->{letter};
	$self->_set_height( $H{ $self->letter // $args->{letter} } );
}

1;
