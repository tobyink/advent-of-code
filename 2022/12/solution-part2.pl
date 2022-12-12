use v5.24;
use warnings;
use utf8;
use Time::HiRes qw(usleep);
use Term::ANSIScreen qw(cls);

binmode( STDOUT, ':utf8' );

sub height_of {
	my $letter = shift;
	return height_of( 'a' ) if $letter eq 'S';
	return height_of( 'z' ) if $letter eq 'E';
	state $heights = do {
		my $i = 0;
		my %h = map +( $_ => ++$i ), 'a' .. 'z';
		\%h;
	};
	return $heights->{$letter};
}

my $grid = do {
	local @ARGV = 'input.txt';
	my @lines = <>;
	chomp for @lines;
	[ map [ map { +{
		letter => $_,
		height => height_of($_),
		distance => $_ eq 'S' ? 0 : undef,
	} } split // ], @lines ];
};

sub check_grid {
	my $E = undef;
	my $str = '';
	for my $row ( $grid->@* ) {
		$str .= join( q[], map {
			$E = $_->{distance} if $_->{letter} eq 'E';
			defined($_->{distance})
				? sprintf( '%s%02d', $_->{letter}, $_->{distance} % 100 )
				: sprintf( '%s--', $_->{letter} )
		} $row->@* ) . "\n";
	}
	say $str;
	return $E;
}

sub _maybe_fill {
	my ( $r1, $c1, $r2, $c2, $n ) = @_;
	return if ! defined($grid->[$r2][$c2]{distance});
	return if $grid->[$r2][$c2]{distance} >= $n;
	my $height1 = $grid->[$r1][$c1]{height};
	my $height2 = $grid->[$r2][$c2]{height};
	return if $height1 > $height2 + 1;
	$grid->[$r1][$c1]{distance} = $n;
}

my $empties = 1;
my $count = 0;
while ( $empties ) {
	++$count;
	$empties = 0;
	for my $row ( 0 .. $#{ $grid } ) {
		for my $col ( 0 .. $#{ $grid->[0] } ) {
			next if defined $grid->[$row][$col]{distance};
			++$empties;
			_maybe_fill( $row, $col, $row-1, $col, $count ) if $row > 0;
			_maybe_fill( $row, $col, $row, $col-1, $count ) if $col > 0;
			_maybe_fill( $row, $col, $row+1, $col, $count ) if $row < $#{ $grid };
			_maybe_fill( $row, $col, $row, $col+1, $count ) if $col < $#{ $grid->[0] };
		}
	}
	usleep(200_000);
	print cls();
	say "Step $count";
	my $E = check_grid( $grid );
	if ( defined $E ) {
		say "E distance: $E";
		last;
	}
	else {
		say "";
	}
}
