#!perl
use v5.24;
use warnings;

use Data::Dumper;
$Data::Dumper::Indent = 0;

package Instruction {
	use Moo::Role;
	has cycles_to_run => ( is => 'rw', lazy => !!1, builder => !!1 );
	sub start_cycle {
		my ( $self, $machine ) = @_;
	}
	sub end_cycle {
		my ( $self, $machine ) = @_;
		$self->cycles_to_run( $self->cycles_to_run - 1 );
	}
}

package Instruction::Noop {
	use Moo; with 'Instruction';
	sub _build_cycles_to_run {
		return 1;
	}
}

package Instruction::Addx {
	use Moo; with 'Instruction';
	has n => ( is => 'ro' );
	sub _build_cycles_to_run {
		return 2;
	}
	after end_cycle => sub {
		my ( $self, $machine ) = @_;
		$machine->register->{x} += $self->n unless $self->cycles_to_run;
	};
}

package Machine {
	use Moo;
	has register => ( is => 'ro', builder => sub { {} } );
	has stack    => ( is => 'ro', builder => sub { [] } );
	sub load_instructions {
		my ( $self, $filename ) = @_;
		local @ARGV = $filename;
		while ( <> ) {
			chomp;
			if ( /^noop$/ ) {
				push $self->stack->@*, Instruction::Noop->new;
			}
			elsif ( /^addx (.+)$/ ) {
				push $self->stack->@*, Instruction::Addx->new( n => 0 + $1 );
			}
		}
		return $self;
	}
	sub run {
		my ( $self, $callback ) = @_;
		my $count = 0;
		CYCLE: while () {
			++$count;
			my $i = $self->stack->[0] or last CYCLE;
			$i->start_cycle( $self );
			$callback->( $self, $i, $count ) if $callback;
			$i->end_cycle( $self );
			$i->cycles_to_run or shift( $self->stack->@* );
		}
	}
}

my $input = 'input.txt';

PART_1: {
	my $total = 0;
	my $machine = Machine->new->load_instructions( $input );
	$machine->register->{x} = 1;
	$machine->run( sub {
		my ( $machine, $instruction, $cycle_number ) = @_;
		if ( 0 == ($cycle_number+20) % 40 ) {
			$total += $cycle_number * $machine->register->{x};
		}
	} );
	say "Sum of six strengths: $total\n";
}

# There are some bugs in the final column of the output, but it's readable.
PART_2: {
	my @pixels = ( '.' ) x 40;
	my $machine = Machine->new->load_instructions( $input  );
	$machine->register->{x} = 1;
	$machine->run( sub {
		my ( $machine, $instruction, $cycle_number ) = @_;
		my $x = $machine->register->{x};
		$cycle_number %= 40;
		if ( $cycle_number == 0 ) {
			say join '', @pixels;
			@pixels = ( '.' ) x 40;
		}
		my %sprite = map +( $_ => 1 ), $x .. $x+2;
		$pixels[$cycle_number-1] = $sprite{$cycle_number} ? '#' : '.';
	} );
}
