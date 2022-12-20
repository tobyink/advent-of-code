package Knot;

use Moo;
use experimental qw( signatures );

has [ 'row', 'col' ] => ( is => 'rw', required => !!1 );
has [ 'history' ]    => ( is => 'ro', builder => sub { {} } );

sub BUILD ( $self, $args ) {
	$self->track_history;
}

sub move ( $self, $direction ) {
	$self->row( $self->row - 1 ) if $direction =~ /U/;
	$self->row( $self->row + 1 ) if $direction =~ /D/;
	$self->col( $self->col - 1 ) if $direction =~ /L/;
	$self->col( $self->col + 1 ) if $direction =~ /R/;
	$self->track_history;
}

sub follow ( $self, $other ) {
	return
		if abs( $self->row - $other->row ) <= 1
		&& abs( $self->col - $other->col ) <= 1;
	my $direction = '';
	$direction .= 'U' if $self->row > $other->row;
	$direction .= 'D' if $self->row < $other->row;
	$direction .= 'L' if $self->col > $other->col;
	$direction .= 'R' if $self->col < $other->col;
	$self->move( $direction );
}

sub track_history ( $self ) {
	++$self->history->{ join q[,], $self->row, $self->col };
}

sub history_size ( $self ) {
	scalar keys $self->history->%*;
}

1;
