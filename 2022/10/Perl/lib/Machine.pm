use v5.24;
use warnings;

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

1;
