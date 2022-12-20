package Situation;

use Prelude -class;

has magic => (
	is => 'lazy',
	isa => Int,
	builder => sub ( $self ) {
		List::Util::product( map $_->item_test->divisor, $self->all_monkeys )
	},
);

has serenity => (
	is => 'rw',
	isa => Bool,
	default => true,
	handles_via => 'Bool',
	handles => {
		serenity_now => 'set',
		serenity_never => 'unset',
	},
);

has round_counter => (
	is => 'ro',
	isa => Int,
	default => 0,
	handles_via => 'Counter',
	handles => {
		_start_round => 'inc',
	}
);

has monkeys => (
	is => 'ro',
	isa => ArrayRef[ InstanceOf[ 'Monkey' ] ],
	handles_via => 'Array',
	handles => {
		get_monkey  => 'get',
		set_monkey  => 'set',
		all_monkeys => 'all',
	},
);

signature_for new_from_filename => (
	method => true,
	pos    => [ Str ],
);
sub new_from_filename ( $class, $filename ) {
	open( my $fh, '<', $filename );
	$class->new_from_file( $fh );
}

signature_for new_from_file => (
	method => true,
	pos    => [ FileHandle ],
);
sub new_from_file ( $class, $fh ) {
	my $self = $class->new;
	while ( <$fh> ) {
		chomp;
		next if !$_;
		if ( /^Monkey (\d+)/ ) {
			my $n = $1 + 0;
			my $m = Monkey->new_from_file( $n, $fh );
			$self->set_monkey( $n, $m );
		}
		else {
			die( "Unknown line: $_" );
		}
	}
	return $self;
}

signature_for run_round => (
	method => true,
	pos    => [],
);
sub run_round ( $self ) {
	$self->_start_round;
	say "Round ", $self->round_counter, ":" if ::DEBUG;
	for my $monkey ( $self->all_monkeys ) {
		$monkey->take_turn( $self );
	}
	say "End of round!\n" if ::DEBUG;
	return $self;
}

signature_for apply_relief => (
	method => true,
	pos    => [ 'StolenItem' ],
);
sub apply_relief ( $self, $item ) {
	my $new = $item->worry_level;
	if ( $self->serenity ) {
		$new /= 3;
	}
	else {
		$new %= $self->magic;
	}
	$item->worry_level( int $new );
}

signature_for print_situation => (
	method => true,
	pos    => [],
);
sub print_situation ( $self ) {
	for my $m ( $self->all_monkeys ) {
		printf(
			"Monkey %d: %s\n",
			$m->number,
			join( q[, ], map $_->worry_level, $m->all_items ),
		);
	}
	say "";
}

1;
