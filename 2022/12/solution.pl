# This is slower than necessary, but animates nicely.
# You'll need a small terminal font.

use v5.24;
use warnings;
use experimental qw( signatures );
use Time::HiRes qw(usleep);
use Term::ANSIScreen qw(cls);

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

sub check_grid ( $grid, $end_point ){
	my $E = undef;
	my $str = '';
	for my $row ( $grid->@* ) {
		$str .= join( q[], map {
			$E //= $_->{distance} if $_->{letter} =~ $end_point;
			defined($_->{distance})
				? sprintf( '%s%02d', $_->{letter}, $_->{distance} % 100 )
				: sprintf( '%s--', $_->{letter} )
		} $row->@* ) . "\n";
	}
	wantarray ? ( $E, $str ) : $E;
}

sub _maybe_fill ( $grid, $r1, $c1, $r2, $c2, $n, $reversed ) {
	return if ! defined($grid->[$r2][$c2]{distance});
	return if $grid->[$r2][$c2]{distance} >= $n;
	my $height1 = $grid->[$r1][$c1]{height};
	my $height2 = $grid->[$r2][$c2]{height};
	if ( $reversed ) {
		return if $height2 > $height1 + 1;
	}
	else {
		return if $height1 > $height2 + 1;
	}
	$grid->[$r1][$c1]{distance} = $n;
}

sub simulation ( $desc, $filename, $start_point, $end_point, $reversed=0 ) {
	my $grid = do {
		local @ARGV = $filename;
		my @lines = <>;
		chomp for @lines;
		[ map [ map { +{
			letter => $_,
			height => height_of($_),
			distance => /$start_point/ ? 0 : undef,
		} } split // ], @lines ];
	};

	my $empties = 1;
	my $count = 0;
	while ( $empties ) {
		++$count;
		$empties = 0;
		for my $row ( 0 .. $#{ $grid } ) {
			for my $col ( 0 .. $#{ $grid->[0] } ) {
				next if defined $grid->[$row][$col]{distance};
				++$empties;
				_maybe_fill( $grid, $row, $col, $row-1, $col, $count, $reversed ) if $row > 0;
				_maybe_fill( $grid, $row, $col, $row, $col-1, $count, $reversed ) if $col > 0;
				_maybe_fill( $grid, $row, $col, $row+1, $col, $count, $reversed ) if $row < $#{ $grid };
				_maybe_fill( $grid, $row, $col, $row, $col+1, $count, $reversed ) if $col < $#{ $grid->[0] };
			}
		}
		my ( $final, $str ) = check_grid( $grid, $end_point );

		print cls();
		say "Step $count";
		say $str;
		usleep(50_000);

		if ( defined $final ) {
			say "$desc: $final";
			say "Hit Ctrl+D to continue";
			my $got = <>;
			return;
		}
	}
}

simulation( "Part 1", 'input.txt', qr/^S$/,    qr/^E$/ );
simulation( "Part 2", 'input.txt', qr/^[aS]$/, qr/^E$/ );
