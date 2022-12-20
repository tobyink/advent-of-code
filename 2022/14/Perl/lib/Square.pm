package Square;

use utf8;
use Prelude;

use constant {
	AIR    => 0,
	ROCK   => 1,
	SAND   => 2,
	FLOOR  => 3,
};

signature_for render => (
	method => 1,
	pos    => [ Int ],
);
sub render ( $class, $material ) {
	state $character = [ '·', '█', '▒', '▓' ];
	$character->[$material];
}

1;
