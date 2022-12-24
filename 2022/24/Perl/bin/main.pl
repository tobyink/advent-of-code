#!perl
use v5.24;
use warnings;
use experimental qw( signatures );
use constant FILENAME => $ENV{ADVENT_INPUT};

use Data::Dumper;
use State ();
use State::Start ();
use Valley ();

sub part1 () {
	my $state = Valley::->read_from_file( FILENAME )
		->starting_state
		->find_path_until( sub ( $state ) {
			$state->isa( 'State::End' )
		} );
	say "PART1: ", $state->minute;
}

sub part2 () {
	my $valley = Valley::->read_from_file( FILENAME );

	my $first_trip = $valley
		->starting_state
		->find_path_until( sub ( $state ) {
			$state->isa( 'State::End' )
		} );
	say "Initial trip in ", $first_trip->minute, " minutes.";

	my $second_trip = $valley
		->ending_state( $first_trip->minute )
		->find_path_until( sub ( $state ) {
			$state->isa( 'State::Start' )
		} );
	say "Back tracking brought us to ", $second_trip->minute, " minutes.";

	my $third_trip = $valley
		->starting_state( $second_trip->minute )
		->find_path_until( sub ( $state ) {
			$state->isa( 'State::End' )
		} );
	say "Final trip brought us to ", $third_trip->minute, " minutes.";

	say "PART2: ", $third_trip->minute; # 803 too low?
}

unless ( caller ) {
	part1();
	part2();
}

