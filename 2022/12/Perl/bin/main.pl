use v5.24;
use warnings;
use Time::HiRes ();
use Term::ANSIScreen ();

use constant FILENAME => $ENV{ADVENT_INPUT};

use Square;
use Map;

defined( $ENV{VISUALIZE} )
	or say "Set the VISUALIZE environment variable for a pretty display.";

Map->load(
	description => 'PART1',
	filename    => FILENAME,
	start_point => qr/^S$/,
	end_point   => qr/^E$/,
)->run_simulation();

Map->load(
	description => 'PART2',
	filename    => FILENAME,
	start_point => qr/^[Sa]$/,
	end_point   => qr/^E$/,
)->run_simulation();
