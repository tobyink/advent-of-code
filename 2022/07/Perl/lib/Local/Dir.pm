use v5.24;
use warnings;
use List::Util ();

package Local::Dir;

use Moo;
extends 'Local::File';

has contents => ( is => 'ro', builder => sub { [] } );
has '+size' => ( required => !!0, default => 0 );

sub _build_total_size {
	my ( $self ) = @_;
	return List::Util::sum(
		$self->size,
		map( $_->total_size, $self->contents->@* ),
	);
}

sub add_child {
	my ( $self, @children ) = @_;
	$_->parent( $self ) for @children;
	push( $self->contents->@*, @children );
	return( wantarray ? @children : $children[0] );
}

sub make_child {
	my ( $self, $class, $name, %spec ) = @_;
	return $self->add_child( $class->new( name => $name, %spec ) );
}

sub get_child {
	my ( $self, $name ) = @_;
	my @found = grep( $_->name eq $name, $self->contents->@* );
	die if @found > 1;
	return $found[0];
}

1;
