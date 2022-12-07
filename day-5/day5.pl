#!/usr/bin/env perl

# vim: filetype=perl

use v5.24;
use warnings;

package Local::Crate {
	use Moo;
	use Sub::HandlesVia;
	use Types::Common -types, -lexical;

	has letter => (
		is => 'ro',
		isa => Str,
		required => !!1,
	);
}

package Local::Stack {
	use Moo;
	use Sub::HandlesVia;
	use Types::Common -types, -lexical;

	has number => (
		is => 'ro',
		isa => PositiveInt,
		required => !!1,
	);

	has position => (
		is => 'ro',
		isa => PositiveInt,
		required => !!1,
	);

	has crates => (
		is => 'ro',
		isa => ArrayRef->of( InstanceOf->of( 'Local::Crate' ) ),
		builder => sub { [] },
		handles_via => 'Array',
		handles => {
			push_crate => 'push',
			pop_crate => 'pop',
			all_crates => 'all',
			find_crate_by_height => 'get',
		},
	);
}

package Local::StackList {
	use Moo;
	use Sub::HandlesVia;
	use Types::Common -types, -lexical, -sigs;
	use constant BIG_NUM => 2048;
	use constant CRATE_MOVER => $ENV{CRATE_MOVER};

	if ( not defined CRATE_MOVER ) {
		die "Set the CRATE_MOVER environment variable to 9000 or 9001.";
	}

	has stacks => (
		is => 'ro',
		isa => ArrayRef->of( InstanceOf->of( 'Local::Stack' ) ),
		builder => sub { [] },
		handles_via => 'Array',
		handles => {
			add_stack => 'push',
			find_stack => 'first',
			all_stacks => 'all',
		},
	);

	sub find_stack_by_number {
		state $sig = signature(
			method     => 1,
			positional => [ PositiveInt ],
		);
		my ( $self, $n ) = &$sig;
		$self->find_stack( sub { $_->number == $n } );
	}

	sub find_stack_by_position {
		state $sig = signature(
			method     => 1,
			positional => [ PositiveInt ],
		);
		my ( $self, $p ) = &$sig;
		$self->find_stack( sub { $_->position == $p } );
	}

	sub run_script {
		state $sig = signature(
			method     => 1,
			positional => [ FileHandle ],
		);
		my ( $self, $fh ) = &$sig;

		$self->_parse_initial_stacks( $fh );
		$self->_parse_instructions( $fh );
	}

	sub _parse_initial_stacks {
		my ( $self, $fh ) = @_;

		my @lines;
		while ( <$fh> ) {
			chomp;
			last if !$_;
			unshift @lines, $_;
		}

		my $stack_labels = shift @lines;
		while ( $stack_labels =~ /(\d+)/g ) {
			$self->add_stack( Local::Stack::->new(
				number    => $1,
				position  => $-[0],
			) );
		}

		for my $line ( @lines ) {
			while ( $line =~ /(\w+)/g ) {
				my $crate = Local::Crate::->new( letter => $1 );
				my $stack = $self->find_stack_by_position( $-[0] );
				$stack->push_crate( $crate );
			}
		}
	}

	sub _parse_instructions {
		my ( $self, $fh ) = @_;

		while ( <$fh> ) {
			chomp;
			last if !$_;
			$self->handle_instruction( $_ );
		}
	}

	sub handle_instruction {
		state $sig = signature(
			method     => 1,
			positional => [ Str ],
		);
		my ( $self, $str ) = &$sig;

		if ( $str =~ /^move (\d+) from (\w+) to (\w+)/ ) {
			$self->handle_move(
				count  => "$1",
				source => "$2",
				dest   => "$3",
			);
		}
		else {
			warn "Unknown instruction: $str";
		}
	}

	sub handle_move {
		state $sig = signature(
			method => 1,
			named  => [
				count  => PositiveInt,
				source => PositiveInt,
				dest   => PositiveInt,
			],
		);
		my ( $self, $move ) = &$sig;

		my $source = $self->find_stack_by_number( $move->source );
		my $dest   = $self->find_stack_by_number( $move->dest );

		if ( CRATE_MOVER >= 9001 ) {
			my @crates;
			for my $i ( 1 .. $move->count ) {
				my $crate = $source->pop_crate;
				if ( not $crate ) {
					warn "Not enough crates to execute move!";
					last;
				}
				unshift @crates, $crate;
			}
			$dest->push_crate( @crates );
		}
		else {
			for my $i ( 1 .. $move->count ) {
				my $crate = $source->pop_crate;
				if ( not $crate ) {
					warn "Not enough crates to execute move!";
					last;
				}
				$dest->push_crate( $crate );
			}
		}
	}

	sub dump {
		state $sig = signature(
			method     => 1,
			positional => [],
		);
		my ( $self ) = &$sig;

		my @lines;

		BASE: {
			my $stack_labels = " " x BIG_NUM;
			STACK: for my $stack ( $self->all_stacks ) {
				substr( $stack_labels, $stack->position, length($stack->number) )
					= $stack->number;
			}
			push @lines, $stack_labels;
		}

		my $height = 0;
		my $keep_going = 1;
		HEIGHT: while ( $keep_going ) {
			$keep_going = 0;
			my $line = " " x BIG_NUM;
			STACK: for my $stack ( $self->all_stacks ) {
				my $crate = $stack->find_crate_by_height( $height )
					or next STACK;
				++$keep_going;
				substr( $line, $stack->position - 1, length($crate->letter) + 2 )
					= sprintf( '[%s]', $crate->letter );
			}
			push @lines, $line;
			++$height;
		}

		s/\s+$// for @lines;
		return join "\n", reverse @lines;
	}
}

open my $fh, '<', 'input.txt';
my $stack_list = Local::StackList->new;
$stack_list->run_script( $fh );
say $stack_list->dump;
