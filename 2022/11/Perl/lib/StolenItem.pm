package StolenItem;

use Prelude -class;

has worry_level => (
	is => 'rw',
	isa => Int,
	required => true,
);

1;
