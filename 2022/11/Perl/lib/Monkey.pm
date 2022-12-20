package Monkey;

use Prelude -class;

has number => (
	is => 'ro',
	isa => Int,
	required => true,
);

has inspection_count => (
	is => 'ro',
	isa => Int,
	default => 0,
	handles_via => 'Counter',
	handles => {
		_increase_inspection_count => 'inc',
	},
);

has items => (
	is => 'ro',
	isa => ArrayRef[ InstanceOf[ 'StolenItem' ] ],
	handles_via => 'Array',
	handles => {
		peek_item           => [ 'get', 0 ],
		item_for_inspection => 'shift',
		accept_item         => 'push',
		item_count          => 'count',
		all_items           => 'all',
	},
);

has operation => (
	is => 'ro',
	isa => InstanceOf[ 'Operation' ],
	handles => {
		apply_operation_to_item => 'apply_to_item',
		operation_description => 'description',
	},
);

has item_test => (
	is => 'ro',
	isa => ConsumerOf[ 'ItemTest' ],
	handles => {
		run_test => 'run_test',
		item_test_description => 'description',
	},
);

has test_actions => (
	is => 'ro',
	isa => HashRef[Int],
	handles_via => 'Hash',
	handles => {
		get_test_action => 'get',
	},
);

signature_for new_from_file => (
	method => true,
	pos    => [ Int, FileHandle ],
);
sub new_from_file ( $class, $n, $fh ) {
	my @items = do {
		my $line = <$fh>;
		$line =~ /^\s*Starting items: (.+?)\s*$/ or die;
		map {
			StolenItem->new( worry_level => $_ )
		} split /\s*,\s*/, "$1";
	};

	my $operation = do {
		my $line = <$fh>;
		$line =~ /^\s*Operation: (.+?)\s*$/ or die;
		my $str = $1;
		Operation->parse_from_string( $str );
	};

	my $test = do {
		my $line = <$fh>;
		$line =~ /^\s*Test: (.+?)\s*$/ or die;
		my $str = $1;
		ItemTest->parse_from_string( $str );
	};

	my %actions;
	while ( <$fh> ) {
		if ( /If (.+?): throw to monkey (\d+)/ ) {
			$actions{"$1"} = $2 + 0;
		}
		else {
			last;
		}
	}

	return $class->new(
		number => $n,
		items => \@items,
		operation => $operation,
		item_test => $test,
		test_actions => \%actions,
	);
}

signature_for take_turn => (
	method => true,
	pos    => [ Object ],
);
sub take_turn ( $self, $situation ) {
	say "  Monkey ", $self->number, ":" if ::DEBUG;
	while ( my $item = $self->item_for_inspection ) {
		$self->do_inspection( $situation, $item );
	}
	say "  ... No more items." if ::DEBUG;
}

signature_for do_inspection => (
	method => true,
	pos    => [ 'Situation', 'StolenItem' ],
);
sub do_inspection ( $self, $situation, $item ) {
	$self->apply_operation_to_item( $item );
	$situation->apply_relief( $item );
	my $result = $self->run_test( item => $item, monkey => $self );
	my $action = $self->get_test_action( $result );
	$situation->get_monkey( $action )->accept_item( $item );
	$self->_increase_inspection_count;
}

1;
