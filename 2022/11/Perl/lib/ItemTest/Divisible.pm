package ItemTest::Divisible;

use Prelude -class;
with 'ItemTest';

has divisor => (
	is => 'ro',
	isa => Int,
	required => true,
);

sub run_test ( $self, $arg ) {
	( $arg->item->worry_level % $self->divisor ) ? 'false' : 'true';
}

1;
