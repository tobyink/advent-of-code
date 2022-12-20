#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use List::Util qw();

package Blueprint {
	use Moo;

	has number         => ( is => 'ro', default => 0 );
	has ore_robot      => ( is => 'ro', default => 0 );
	has clay_robot     => ( is => 'ro', default => 0 );
	has obsidian_robot => ( is => 'ro', default => 0 );
	has geode_robot    => ( is => 'ro', default => 0 );

	sub parse_from_string {
		my ( $class, $str ) = @_;
		$str =~ /Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./ or die;
		return $class->new(
			number         => $1,
			ore_robot      => { ore => $2 },
			clay_robot     => { ore => $3 },
			obsidian_robot => { ore => $4, clay => $5 },
			geode_robot    => { ore => $6, obsidian => $7 },
		);
	}

	sub parse_from_file {
		my ( $class, $filename ) = @_;
		open my $fh, '<', $filename or die;
		return map $class->parse_from_string( $_ ), <$fh>;
	}
}

package State {
	use Moo;
	has is_bad         => ( is => 'rw', default => 0 );
	has parent         => ( is => 'ro', required => 1 );
	has desc           => ( is => 'ro' );
	has ore            => ( is => 'rw', default => 0 );
	has clay           => ( is => 'rw', default => 0 );
	has obsidian       => ( is => 'rw', default => 0 );
	has geode          => ( is => 'rw', default => 0 );
	has ore_robot      => ( is => 'rw', default => 0 );
	has clay_robot     => ( is => 'rw', default => 0 );
	has obsidian_robot => ( is => 'rw', default => 0 );
	has geode_robot    => ( is => 'rw', default => 0 );
	has building_ore_robot      => ( is => 'rw', default => 0 );
	has building_clay_robot     => ( is => 'rw', default => 0 );
	has building_obsidian_robot => ( is => 'rw', default => 0 );
	has building_geode_robot    => ( is => 'rw', default => 0 );

	sub dump {
		my ( $self ) = @_;
		sprintf(
			'%3d %3d %3d %3d %3d %3d %3d %3d',
			$self->ore,
			$self->clay,
			$self->obsidian,
			$self->geode,
			$self->ore_robot,
			$self->clay_robot,
			$self->obsidian_robot,
			$self->geode_robot,
		);
	}

	sub is_objectively_worse_than {
		my ( $self, $other ) = @_;
		for my $material ( qw/ geode obsidian clay ore / ) {
			my $robots = $material . "_robot";
			return 0 if $self->$material > $other->$material;
			return 0 if $self->$robots > $other->$robots;
		}
		return "$self" lt "$other";
	}

	sub finish_robot_work {
		my ( $self ) = @_;
		for my $material ( qw/ geode obsidian clay ore / ) {
			my $robots = $material . "_robot";
			$self->$material( $self->$material + $self->$robots );
		}
	}

	sub finish_building_robots {
		my ( $self ) = @_;
		for my $material ( qw/ geode obsidian clay ore / ) {
			my $robots   = $material . "_robot";
			my $building = "building_$robots";
			if ( $self->$building ) {
				$self->$robots( $self->$robots + $self->$building );
				$self->$building( 0 );
			}
		}
	}

	sub clone {
		my ( $self, %args ) = @_;
		bless { $self->%*, %args }, ref( $self );
	}

	{
		no warnings 'once';
		*but = \&clone;
	}

	sub do_nothing {
		my ( $self ) = @_;
		return $self->but( parent => $self, desc => undef );
	}

	sub maybe_build_robot {
		my ( $self, $blueprint, $robot ) = @_;
		my %costs = $blueprint->$robot->%*;
		for my $material ( keys %costs ) {
			return unless $self->$material >= $costs{$material};
		}
		my $next = $self->but(
			parent => $self,
			"building_$robot" => 1,
			desc => "$robot built",
		);
		for my $material ( keys %costs ) {
			$next->$material( $next->$material - $costs{$material} );
		}
		return $next;
	}

	sub next_states {
		my ( $self, $blueprint ) = @_;
		my @next_states =
			map $self->maybe_build_robot( $blueprint, "$_\_robot" ),
			qw( ore geode obsidian clay);
		push @next_states, $self->do_nothing;
		$_->finish_robot_work for @next_states;
		$_->finish_building_robots for @next_states;
		return @next_states;
	}

	sub explain {
		my ( $self, $minute ) = @_;
		my $explain = sprintf(
			"Minute: %d\n  Ore: %2d (+%2d); Clay: %2d (+%2d); Obsidian: %2d (+%2d); Geode: %2d (+%2d)\n",
			$minute,
			$self->ore,       $self->ore_robot,
			$self->clay,      $self->clay_robot,
			$self->obsidian,  $self->obsidian_robot,
			$self->geode,     $self->geode_robot,
		);
		if ( $self->parent ) {
			$explain = $self->parent->explain( $minute - 1 ) . $explain;
		}
		if ( $self->desc ) {
			$explain .= "  " . $self->desc . "\n";
		}
		return $explain;
	}

	sub more_progress_than {
		my ( $self, $other ) = @_;
		return $other->geode < $self->geode unless $other->geode == $self->geode;
		return $other->obsidian < $self->obsidian unless $other->obsidian == $self->obsidian;
		return $other->clay < $self->clay unless $other->clay == $self->clay;
		return $other->ore < $self->ore;
	}

	sub progress_all {
		my ( $states, $blueprint ) = @_;
		$states->@* = map $_->next_states( $blueprint ), $states->@*;
	}

	sub filter_bad {
		my ( $states, $blueprint, $remaining_minutes ) = @_;

		my ( %most_we_need_per_minute, %most_we_need_ever );
		for my $material ( qw/ ore clay obsidian / ) {
			$most_we_need_per_minute{$material} = List::Util::max(
				grep defined,
				map $_->{$material}, (
					$blueprint->ore_robot,
					$blueprint->clay_robot,
					$blueprint->obsidian_robot,
					$blueprint->geode_robot,
				)
			);

#			$most_we_need_ever{$material} = $most_we_need_per_minute{$material};
#			$most_we_need_ever{$material} *= List::Util::max( 1, $remaining_minutes );
		}

		STATE: for my $x ( $states->@* ) {
			# Exclude geodes from this!
			MATERIAL: for my $material ( qw/ ore clay obsidian / ) {
				my $robot = "$material\_robot";
				my $production_capacity_per_minute = $x->$robot;
				my $supply = $x->$material;
				# We don't need more robots than we need of a material per minute.
				if ( $production_capacity_per_minute > $most_we_need_per_minute{$material} ) {
					$x->is_bad( 1 );
					next STATE;
				}
#				# We don't need more raw material than we'll ever need of a material.
#				if ( $remaining_minutes > 1 and $supply > $most_we_need_ever{$material}) {
#					$x->is_bad( 1 );
#					next STATE;
#				}
			}
		}
		$states->@* = grep !$_->is_bad, $states->@*;

		# Filter out states which are objectively worse
		my @keep = ();
		MAYBE: for my $maybe_keep ( $states->@* ) {
			for my $kept_ix ( 0 .. $#keep ) {
				my $kept = $keep[$kept_ix];
				if ( $maybe_keep->is_objectively_worse_than( $kept ) ) {
					next MAYBE;
				}
				elsif ( $kept->is_objectively_worse_than( $maybe_keep ) ) {
					$keep[$kept_ix] = $maybe_keep;
					next MAYBE;
				}
			}
			push @keep, $maybe_keep;
		}
		$states->@* = grep !$_->is_bad, @keep;
	}
}

sub part1 {
	local $| = 1;

	my @blueprints = Blueprint::->parse_from_file( 'input-test.txt' );

	my $best_blueprint = undef;
	my $best_blueprint_state  = undef;
	my $total_quality_level = 0;

	for my $blueprint ( @blueprints ) {

		say "# Blueprint ", $blueprint->number;
		say "";

		my @states = ( State->new( parent => undef, ore_robot => 1 ) );

		my $total_time = 24;
		for my $min ( 1 .. $total_time ) {
			say "## Minute $min";
			State::progress_all( \@states, $blueprint );
			say "Next states: ", scalar @states;
			State::filter_bad( \@states, $blueprint, $total_time - $min );
			say "Filtered to: ", scalar @states;
		}

		my $best = $states[0];
		for my $s ( @states ) {
			$best = $s if $s->more_progress_than( $best );
		}
		
		say "** Blueprint ", $blueprint->number, " can produce ", $best->geode, " geodes. **";
		say "";
		say $best->explain( $total_time );
		say "";
		
		my $quality_level = $best->geode * $blueprint->number;
		say "Quality level: $quality_level";
		say "";

		$total_quality_level += $quality_level;
		
		if ( !$best_blueprint_state or $best->more_progress_than( $best_blueprint_state ) ) {
			$best_blueprint = $blueprint;
			$best_blueprint_state = $best;
		}
	}

	say "Blueprint ", $best_blueprint->number, " wins with state:";
	say $best_blueprint_state->dump;
	say "";
	
	say "Total quality level: $total_quality_level";
	say "";
}

part1();
