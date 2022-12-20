use v5.24;
use warnings;

package Local::Crate;
use Moo;
use Sub::HandlesVia;
use Types::Common -types;

has letter => (
	is => 'ro',
	isa => Str,
	required => !!1,
);

1;
