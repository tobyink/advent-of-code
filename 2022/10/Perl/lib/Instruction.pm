use v5.24;
use warnings;

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

1;