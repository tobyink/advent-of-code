package ItemTest;

use Prelude -role;
requires 'run_test';

has description => (
	is => 'ro',
	isa => Str,
	required => true,
);

around run_test => signature(
	method    => true,
	goto_next => true,
	named     => [
		monkey  => InstanceOf[ 'Monkey' ],
		item    => InstanceOf[ 'StolenItem' ],
	],
);

signature_for parse_from_string => (
	method => true,
	pos    => [ Str ],
);
sub parse_from_string ( $class, $str ) {
	if ( $str =~ /divisible by (\d+)/ ) {
		return ItemTest::Divisible->new( description => $str, divisor => $1 + 0 );
	}
	die( "Could not parse ItemTest from string: $str" );
}

1;
