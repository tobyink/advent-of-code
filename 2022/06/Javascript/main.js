require( 'fs' ).readFile( process.env.ADVENT_INPUT, 'utf8', ( err, input ) => {
	if ( err ) {
		console.error( err );
		return;
	}
	console.log( `PART1: ${ find_marker( input, 4 ) }` );
	console.log( `PART2: ${ find_marker( input, 14 ) }` );
} );

function find_marker( buffer, marker_size ) {
	for ( var pos = marker_size; pos < buffer.length; pos++ ) {
		let chars = {};
		for ( var c = pos - marker_size; c < pos; c++ ) {
			chars[buffer.charAt(c)] = 1;
		}
		if ( Object.keys( chars ).length == marker_size ) return pos;
	}
	return false;
}
