use v5.24;
use warnings;
use experimental qw( signatures );

package State;

# Using constants instead of accessor methods to access slots in State
# to provide a speed boost.
use constant {
	MINUTES       => 0,
	ORE           => 1,
	CLAY          => 2,
	OBSIDIAN      => 3,
	GEODE         => 4,
	ORE_BOT       => 5,
	CLAY_BOT      => 6,
	OBSIDIAN_BOT  => 7,
	GEODE_BOT     => 8,
};

sub new ( $class, @state ) {
	return bless( \@state, $class );
}

sub new_empty ( $class ) {
	my @state = ( 0 ) x 9;
	return $class->new( @state );
}

1;
