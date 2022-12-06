#!perl
use v5.24;
use warnings;

my $input = do { local ( @ARGV, $/ ) = 'input.txt'; <> };
say "Start of packet:  ", find_marker( \$input, 4 );
say "Start of message: ", find_marker( \$input, 14 );

sub find_marker {
	my ( $buffer, $marker_size ) = @_;
	for my $pos ( $marker_size .. length $$buffer ) {
		my %chars =
			map +( $_ => 1 ),
			unpack(
				'c' x $marker_size,
				substr( $$buffer, $pos - $marker_size, $marker_size ),
			);
		return $pos if keys(%chars) == $marker_size;
	}
	return;
}
