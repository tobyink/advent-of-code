use v5.24;
use warnings;

package Local::File;

use Moo;

has is_root => ( is => 'ro', default => !!0 );
has name => ( is => 'ro', required => !!1 );
has size => ( is => 'ro', required => !!1 );
has parent => ( is => 'rw' );
has total_size => ( is => 'lazy', builder => sub { shift->size } );

sub full_path {
	my ( $self ) = @_;
	my $parent = $self->parent
		or return $self->name;
	return sprintf( '%s/%s', $parent->full_path, $self->name );
}

sub pretty_path {
	my ( $self ) = @_;
	return( $self->is_root ? '/' : $self->full_path );
}

sub display {
	my ( $self ) = @_;
	return sprintf(
		"%-84s %-4s %10d",
		$self->pretty_path,
		substr( ref($self), 7 ),
		$self->total_size,
	);
}

sub BUILD {
	my ( $self ) = @_;
	push( our @ALL, $self );
}

1;
