package Operation;

use Prelude -class;

has description => (
	is => 'ro',
	isa => Str,
	required => true,
);

has code => (
	is => 'ro',
	isa => CodeRef,
	required => true,
	handles_via => 'Code',
	handles => {
		run_code => 'execute',
	},
);

signature_for parse_from_string => (
	method => true,
	pos    => [ Str ],
);
sub parse_from_string ( $class, $str ) {
	my $desc = $str;
	$str =~ s/new/\$new/g;
	$str =~ s/old/\$old/g;
	my $code = sprintf( 'sub { my ( $old, $new ) = @_; %s; return $new }', $str );
	return $class->new( code => eval($code), description => $desc );
}

signature_for apply_to_item => (
	method => true,
	pos    => [ 'StolenItem' ],
);
sub apply_to_item ( $self, $item ) {
	$item->worry_level( $self->run_code( $item->worry_level ) );
	return $self;
}

1;