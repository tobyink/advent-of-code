require( 'fs' ).readFile( 'input.txt', 'utf8', ( err, input ) => {
	if ( err ) {
		console.error( err );
		return;
	}
	console.log( `Start of packet:  ${ find_marker( input, 4 ) }` );
	console.log( `Start of message: ${ find_marker( input, 14 ) }` );
} );

function find_marker( buffer, marker_size ) {
	for ( var pos = marker_size; pos < buffer.length; pos++ ) {
		let chars = {};
		for ( var c = pos - marker_size; c < pos; c++ ) {
			chars[buffer.charAt(c)] = 1;
		}
		if ( Object.keys( chars ).length == marker_size ) return pos;
	}
	return 0;
}
