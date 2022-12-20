#!perl
use v5.24;
use warnings;

use Blueprint;
use State;

use constant FILENAME => $ENV{ADVENT_INPUT};

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
	say "PART1: $quality";
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
	say "PART2: $multiple";
	say "";
}

part1();
part2();
