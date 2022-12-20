package Prelude;

use feature qw( :5.24 );
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
	'feature'->import::into( 1, qw( :5.24 ) );
	'constant'->import::into( 1, { true => !!1, false => !!0 } );
	'namespace::clean'->import::into( 1 );
}

$Data::Dumper::Deparse = 1;
