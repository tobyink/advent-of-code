#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use constant FILENAME => 'input.txt';

package State {
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
}

package Blueprint {
	# Using constants instead of accessor methods to access slots in Blueprint
	# to provide a speed boost.
	use constant {
		BLUEPRINT_NUMBER         => 0,
		COST_ORE_BOT_ORE         => 1,
		COST_CLAY_BOT_ORE        => 2,
		COST_OBSIDIAN_BOT_ORE    => 3,
		COST_OBSIDIAN_BOT_CLAY   => 4,
		COST_GEODE_BOT_ORE       => 5,
		COST_GEODE_BOT_OBSIDIAN  => 6,
	};

	sub read ( $class, $filename ) {
		my @blueprints;
		open my $fh, '<', $filename;
		while ( <$fh> ) {
			chomp;
			my @parts = m/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./ or die;
			push @blueprints, bless( \@parts, $class );
		}
		return @blueprints;
	}

	sub best ( $self, $minutes ) {
		my $best = undef;
		my %visited;

		my $start = State::->new_empty();
		$start->[ State::MINUTES ] = $minutes;
		$start->[ State::ORE_BOT ] = 1;
		my @queue = ( $start );

		require List::Util;
		my $max_needed_ore = List::Util::max(
			$self->[ COST_ORE_BOT_ORE ],
			$self->[ COST_CLAY_BOT_ORE ],
			$self->[ COST_OBSIDIAN_BOT_ORE ],
			$self->[ COST_GEODE_BOT_ORE ],
		);

		while ( @queue ) {
			my $state = shift @queue;
			$visited{ "@$state" }++ and next;

			if ( $state->[ State::MINUTES ] == 0 ) {
				if ( !$best or $best->[ State::GEODE ] < $state->[ State::GEODE ] ) {
					$best = $state;
				}
				next;
			}

			my $new = State::->new( @$state );
			$new->[ State::MINUTES ]--;
			$new->[ State::ORE ]      += $new->[ State::ORE_BOT ];
			$new->[ State::CLAY ]     += $new->[ State::CLAY_BOT ];
			$new->[ State::OBSIDIAN ] += $new->[ State::OBSIDIAN_BOT ];
			$new->[ State::GEODE ]    += $new->[ State::GEODE_BOT ];

			my $maybe_geodebot = (
				$state->[ State::ORE ] >= $self->[ COST_GEODE_BOT_ORE ] and
				$state->[ State::OBSIDIAN ] >= $self->[ COST_GEODE_BOT_OBSIDIAN ]
			);
			if ( $maybe_geodebot ) {
				my $new2 = State::->new( @$new );
				$new2->[ State::GEODE_BOT ]++;
				$new2->[ State::ORE ] -= $self->[ COST_GEODE_BOT_ORE ];
				$new2->[ State::OBSIDIAN ] -= $self->[ COST_GEODE_BOT_OBSIDIAN ];
				push @queue, $new2;
			}

			my $maybe_obsidianbot = (
				!$maybe_geodebot and
				$state->[ State::OBSIDIAN_BOT ] < $self->[ COST_GEODE_BOT_OBSIDIAN ] and
				$state->[ State::ORE ] >= $self->[ COST_OBSIDIAN_BOT_ORE ] and
				$state->[ State::CLAY ] >= $self->[ COST_OBSIDIAN_BOT_CLAY ]
			);
			if ( $maybe_obsidianbot ) {
				my $new2 = State::->new( @$new );
				$new2->[ State::OBSIDIAN_BOT ]++;
				$new2->[ State::ORE ] -= $self->[ COST_OBSIDIAN_BOT_ORE ];
				$new2->[ State::CLAY ] -= $self->[ COST_OBSIDIAN_BOT_CLAY ];
				push @queue, $new2;
			}

			my $maybe_claybot = (
				!$maybe_geodebot and
				!$maybe_obsidianbot and
				$state->[ State::CLAY_BOT ] < $self->[ COST_OBSIDIAN_BOT_CLAY ] and
				$state->[ State::ORE ] >= $self->[ COST_CLAY_BOT_ORE ]
			);
			if ( $maybe_claybot ) {
				my $new2 = State::->new( @$new );
				$new2->[ State::CLAY_BOT ]++;
				$new2->[ State::ORE ] -= $self->[ COST_CLAY_BOT_ORE ];
				push @queue, $new2;
			}

			my $maybe_orebot = (
				!$maybe_geodebot and
				!$maybe_obsidianbot and
				$state->[ State::ORE_BOT ] < $max_needed_ore and
				$state->[ State::ORE ] >= $self->[ COST_ORE_BOT_ORE ]
			);
			if ( $maybe_orebot ) {
				my $new2 = State::->new( @$new );
				$new2->[ State::ORE_BOT ]++;
				$new2->[ State::ORE ] -= $self->[ COST_ORE_BOT_ORE ];
				push @queue, $new2;
			}

			my $maybe_noop = (
				!$maybe_geodebot and
				$state->[ State::ORE ] < ( 2 * $max_needed_ore ) and
				$state->[ State::CLAY ] < ( 3 * $self->[ COST_OBSIDIAN_BOT_CLAY ] )
			);
			if ( $maybe_noop ) {
				push @queue, $new;
			}

		} #/ while

		return $best;
	}
}

sub part1 {
	say "Part 1:";
	my $quality = 0;
	my @blueprints = Blueprint::->read( FILENAME );
	for my $bp ( @blueprints ) {
		my $best = $bp->best( 24 );
		printf(
			"Blueprint %d can crack %d geodes\n",
			$bp->[ Blueprint::BLUEPRINT_NUMBER ],
			$best->[ State::GEODE ],
		);
		$quality += ( $bp->[ Blueprint::BLUEPRINT_NUMBER ] * $best->[ State::GEODE ] );
	}
	say "Quality is $quality";
	say "";
}

sub part2 {
	say "Part 2:";
	my $multiple = 1;
	my @blueprints = Blueprint::->read( FILENAME );
	splice( @blueprints, 3 );
	for my $bp ( @blueprints ) {
		my $best = $bp->best( 32 );
		printf(
			"Blueprint %d can crack %d geodes\n",
			$bp->[ Blueprint::BLUEPRINT_NUMBER ],
			$best->[ State::GEODE ],
		);
		$multiple *= $best->[ State::GEODE ];
	}
	say "Multiple is $multiple";
	say "";
}

part1();
part2();
