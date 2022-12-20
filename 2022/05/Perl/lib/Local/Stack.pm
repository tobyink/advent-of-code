use v5.24;
use warnings;

package Local::Stack;
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

1;
