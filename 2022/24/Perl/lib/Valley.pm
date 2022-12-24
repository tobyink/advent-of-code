use v5.24;
use warnings;

package Valley;

use Moo;
use Types::Common -types;
use experimental qw( signatures );

use Blizzard ();
use Map ();

# Excludes outer walls
has width     => ( is => 'rwp', isa => PositiveOrZeroInt );
has height    => ( is => 'rwp', isa => PositiveOrZeroInt );
has blizzards => ( is => 'ro',  isa => ArrayRef, default => sub { [] } );
has _maps     => ( is => 'ro',  isa => ArrayRef, default => sub { [] } );

sub map_for_minute ( $self, $minute ) {

	return $self->_maps->[$minute]
		if defined $self->_maps->[$minute];

	my $grid = [ map [ ( 0 ) x $self->width ], 1 .. $self->height ];
	for my $b ( $self->blizzards->@* ) {
		my ( $r, $c ) = $b->position_at_minute( $minute );
		$grid->[$r][$c] |= $b->direction;
	}

	$self->_maps->[$minute] = Map::->new( grid => $grid, valley => $self );
}

sub read_from_file ( $class, $filename ) {
	open my $fh, '<', $filename or die;

	my $self = $class->new();

	my $row = 0;
	while ( <$fh> ) {
		chomp;
		next if /###/; s/^#//; s/#$//; # ignore stupid walls
		$self->_set_width( length );
		my $col = 0;
		for ( split // ) {
			my $direction = undef;
			$direction = Blizzard::NORTH if $_ eq '^';
			$direction = Blizzard::SOUTH if $_ eq 'v';
			$direction = Blizzard::EAST  if $_ eq '>';
			$direction = Blizzard::WEST  if $_ eq '<';
			if ( $direction ) {
				push $self->blizzards->@*, Blizzard::->new(
					init_row  => $row,
					init_col  => $col,
					direction => $direction,
					valley    => $self,
				);
			}
			++$col;
		}
		++$row;
	}
	$self->_set_height( $row );

	return $self;
}

sub starting_state ( $self, $minute = 0 ) {
	require State::Start;
	return 'State::Start'->new( valley => $self, minute => $minute );
}

sub ending_state ( $self, $minute = 0 ) {
	require State::End;
	return 'State::End'->new( valley => $self, minute => $minute );
}

1;
