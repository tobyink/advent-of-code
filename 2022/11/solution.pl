use v5.32;
use warnings;
use experimental qw( signatures );
use constant DEBUG => 0;

# A bunch of imports to bring into all the OO packages...
BEGIN {
	package Prelude;
	use constant ();
	use experimental qw( signatures );
	use namespace::clean ();
	use Data::Dumper;
	use Import::Into 1.002000 ();
	use List::Util ();
	use Moo 2.000000 ();
	use Moo::Role ();
	use Scalar::Util ();
	use Sub::HandlesVia 0.045 ();
	use Types::Common 2.000000 ();
	sub import ( $class, $arg = '' ) {
		if ( $arg eq -class ) {
			'Moo'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		elsif ( $arg eq -role ) {
			'Moo::Role'->import::into( 1 );
			'Sub::HandlesVia'->import::into( 1 );
		}
		'Types::Common'->import::into( 1, qw( -sigs -types ) );
		'experimental'->import::into( 1, qw( signatures ) );
		'constant'->import::into( 1, { true => !!1, false => !!0 } );
		'namespace::clean'->import::into( 1 );
	}
	$INC{'Prelude.pm'} = __FILE__;
	$Data::Dumper::Deparse = 1;
};

package Situation {
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
}

package Monkey {
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
}

package StolenItem {
	use Prelude -class;

	has worry_level => (
		is => 'rw',
		isa => Int,
		required => true,
	);
}

package Operation {
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
}

package ItemTest {
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
}

package ItemTest::Divisible {
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
}

PART_1: {
	my $s = Situation->new_from_filename( 'input.txt' );
	$s->run_round for 1 .. 20;
	my @active = sort { $b <=> $a } map $_->inspection_count, $s->all_monkeys;
	say "Part 1: ", $active[0] * $active[1];
}

PART_2: {
	my $s = Situation->new_from_filename( 'input.txt' );
	$s->serenity_never;
	$s->run_round for 1 .. 10_000;
	my @active = sort { $b <=> $a } map $_->inspection_count, $s->all_monkeys;
	say "Part 2: ", $active[0] * $active[1];
}
