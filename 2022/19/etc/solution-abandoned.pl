#!perl
use v5.24;
use warnings;
use experimental qw( signatures );

use constant DEBUG     => !!0;
use constant FILENAME  => 'input-test.txt';
use constant MATERIALS => qw/ ore clay obsidian geode /;

# A bunch of imports to bring into all the OO packages...
BEGIN {
	package Prelude;
	use constant ();
	use experimental qw( signatures );
	use namespace::clean ();
	use Data::Dumper;
	use Import::Into 1.002000 ();
	use List::Util ();
	use Moo 2.000000 ();
	use Moo::Role ();
	use Scalar::Util ();
	use Sub::HandlesVia 0.045 ();
	use Types::Common 2.000000 ();
	sub import ( $class, $arg = '' ) {
		if ( $arg eq -class ) {
			'Moo'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		elsif ( $arg eq -role ) {
			'Moo::Role'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		'Types::Common'->import::into( 1, qw( -sigs -types ) );
		'experimental'->import::into( 1, qw( signatures ) );
		'constant'->import::into( 1, { true => !!1, false => !!0 } );
		'namespace::clean'->import::into( 1 );
	}
	$INC{'Prelude.pm'} = __FILE__;
	$Data::Dumper::Deparse = 1;
};

package Robot {
	use Prelude -role;

	requires 'release_materials';

	has blueprint => (
		is          => 'ro',
		isa         => Object,
	);
}

package Robot::OreCollector {
	use Prelude -class;
	with 'Robot';

	sub release_materials ( $self, $stash ) {
		say "$self supplies 1 ore" if ::DEBUG;
		$stash->supply_ore( 1 );
	}
}

package Robot::ClayCollector {
	use Prelude -class;
	with 'Robot';

	sub release_materials ( $self, $stash ) {
		say "$self supplies 1 clay" if ::DEBUG;
		$stash->supply_clay( 1 );
	}
}

package Robot::ObsidianCollector {
	use Prelude -class;
	with 'Robot';

	sub release_materials ( $self, $stash ) {
		say "$self supplies 1 obsidian" if ::DEBUG;
		$stash->supply_obsidian( 1 );
	}
}

package Robot::GeodeCracker {
	use Prelude -class;
	with 'Robot';

	sub release_materials ( $self, $stash ) {
		say "$self supplies 1 cracked geode" if ::DEBUG;
		$stash->supply_geode( 1 );
	}
}

package Stash {
	use Prelude -class;

	for my $material ( ::MATERIALS ) {
		has $material => (
			is          => 'ro',
			isa         => PositiveOrZeroInt,
			writer      => "set_$material",
			builder     => sub ( $self ) { 0 },
			handles_via => 'Counter',
			handles     => {
				"consume_$material" => 'dec',
				"supply_$material"  => 'inc',
			},
		);
	}

	has robots => (
		is          => 'ro',
		isa         => ArrayRef[ Object ],
		required    => true,
		handles_via => 'Array',
		handles     => {
			'add_robots'        => 'push',
			'all_robots'        => 'all',
			'robot_count'       => 'count',
		},
	);

	sub increase ( $self ) {
		for my $robot ( $self->all_robots ) {
			$robot->release_materials( $self );
		}
	}

	sub satisfies ( $self, $costs ) {
		for my $material ( keys $costs->%* ) {
			return false if $self->$material < $costs->{$material};
		}
		return true;
	}

	sub spend ( $self, $costs ) {
		for my $material ( keys $costs->%* ) {
			my $consume = "consume_$material";
			$self->$consume( $costs->{$material} );
		}
		return $self;
	}

	sub dump ( $self ) {
		my $str = '';
		for my $material ( ::MATERIALS ) {
			$str .= sprintf( "Stash contains %d %s.\n", $self->$material, $material );
		}
		$str .= sprintf( "Stash contains %d robots.\n", $self->robot_count );
	}
}

package Blueprint {
	use Prelude -class;

	has number => (
		is          => 'ro',
		isa         => PositiveInt,
		required    => true,
	);

	has strategy => (
		is          => 'rw',
		isa         => ArrayRef,
		handles     => {
			'objective'         => [ 'get' => 0 ],
		}
	);

	for my $material ( ::MATERIALS ) {
		has "$material\_robot_costs" => (
			is          => 'ro',
			isa         => HashRef[ PositiveOrZeroInt ],
			required    => true,
		);
	}

	has partly_built_robots => (
		is          => 'ro',
		isa         => ArrayRef,
		builder     => sub ( $self ) { [] },
		handles_via => 'Array',
		handles     => {
			'_start_building'    => 'push',
			'_built_robots'      => 'all',
			'_clear_workbench'   => 'clear',
			'_built_robot_count' => 'count',
		}
	);

	sub parse_from_string ( $class, $str ) {
		$str =~ /Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./ or die;
		return $class->new(
			number               => $1,
			ore_robot_costs      => { ore => $2 },
			clay_robot_costs     => { ore => $3 },
			obsidian_robot_costs => { ore => $4, clay => $5 },
			geode_robot_costs    => { ore => $6, obsidian => $7 },
		);
	}

	sub parse_from_file ( $class, $filename ) {
		open my $fh, '<', $filename or die;
		return map $class->parse_from_string( $_ ), <$fh>;
	}

	sub _cycle_strategy ( $self ) {
		my $done = shift $self->strategy->@*;
		push $self->strategy->@*, $done;
		return $self;
	}

	sub build_robots ( $self, $stash ) {
		my $objective = $self->strategy->[0];

		if ( $objective eq 'geode' and $stash->satisfies( $self->geode_robot_costs ) ) {
			say "Start building Robot::GeodeCracker" if ::DEBUG;
			$stash->spend( $self->geode_robot_costs );
			$self->_start_building( Robot::GeodeCracker::->new( blueprint => $self ) );
			$self->_cycle_strategy;
		}
		if ( $objective eq 'clay' and $stash->satisfies( $self->clay_robot_costs ) ) {
			say "Start building Robot::ClayCollector" if ::DEBUG;
			$stash->spend( $self->clay_robot_costs );
			$self->_start_building( Robot::ClayCollector::->new( blueprint => $self ) );
			$self->_cycle_strategy;
		}
		if ( $objective eq 'ore' and $stash->satisfies( $self->ore_robot_costs ) ) {
			say "Start building Robot::OreCollector" if ::DEBUG;
			$stash->spend( $self->ore_robot_costs );
			$self->_start_building( Robot::OreCollector::->new( blueprint => $self ) );
			$self->_cycle_strategy;
		}
	}

	sub release_robots ( $self, $stash ) {
		my $count = $self->_built_robot_count or return;
		say "Finished building $count robots" if ::DEBUG;
		$stash->add_robots( $self->_built_robots );
		$self->_clear_workbench;
	}

	sub all_strategies () {
		my @s;
		for my $a ( ::MATERIALS ) {
			for my $b ( ::MATERIALS ) {
				next if $b eq $a;
				for my $c ( ::MATERIALS ) {
					next if $c eq $a;
					next if $c eq $b;
					for my $d ( ::MATERIALS ) {
						next if $d eq $a;
						next if $d eq $b;
						next if $d eq $c;
						push @s, [ $a, $b, $c, $d ];
					}
				}
			}
		}
		return @s;
	}
	
	sub pretty_strategy ( $s ) {
		join "", map {
			ore      => 'O',
			clay     => 'C',
			obsidian => 'D', # dragon glass
			geode    => 'G',
		}->{$_}, $s->@*;
	}
}

sub part1 () {
	say "Part 1:";
	my @blueprints = Blueprint::->parse_from_file( FILENAME );
	for my $b ( @blueprints ) {
		my @strategies = Blueprint::all_strategies();
		for my $strategy ( @strategies ) {
			say "=====================================" if ::DEBUG;
			printf(
				"==== Blueprint %02d; strategy %s ====\n",
				$b->number,
				Blueprint::pretty_strategy( $strategy ),
			) if ::DEBUG;
			say "=====================================" if ::DEBUG;
			say "" if ::DEBUG;
			$b->strategy( $strategy );
			
			my $initial_robot = Robot::OreCollector::->new( blueprint => $b );
			my $stash = Stash::->new( robots => [ $initial_robot ] );
			for my $minute ( 1 .. 24 ) {
				say "==== Minute $minute ====" if ::DEBUG;
				$b->build_robots( $stash );
				$stash->increase;
				$b->release_robots( $stash );
				say $stash->dump if ::DEBUG;
			}

			printf(
				"Blueprint %02d; strategy %s = %d geodes.\n",
				$b->number,
				Blueprint::pretty_strategy( $strategy ),
				$stash->geode,
			);
		}
	}
}

part1();
