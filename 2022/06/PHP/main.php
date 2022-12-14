<?php

function find_marker ( &$buffer, $marker_size ) {
	$length = strlen( $buffer );
	for ( $pos = $marker_size; $pos <= $length; $pos++ ) {
		$chars = array_unique(
			str_split(
				substr( $buffer, $pos - $marker_size, $marker_size )
			)
		);
		if ( count($chars) == $marker_size )
			return $pos;
	}
	return FALSE;
}

$input = file_get_contents( getenv( 'ADVENT_INPUT' ) );

echo 'PART1: ' . find_marker( $input, 4 ) . "\n";
echo 'PART2: ' . find_marker( $input, 14 ) . "\n";
