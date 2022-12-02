const fs = require( 'fs' );

fs.readFile( 'input.txt', 'utf8', ( err, data ) => {
	if ( err ) {
		console.error( err );
		return;
	}

	var elf_no = 0;
	var calories = [];
	data.split( /\r?\n/ ).forEach( line => {
		if ( line == "" ) {
			elf_no++;
		}
		else {
			if ( ! calories[elf_no] ) {
				calories[elf_no] = 0;
			}
			calories[elf_no] += parseInt( line, 10 );
		}
	} );

	var sorted = calories.map( ( c, e ) => [ e, c ] );
	sorted.sort( ( a, b ) => ( a[1] < b[1] ) ? 1 : ( ( a[1] > b[1] ) ? -1 : 0 ) );

	console.log( `Elf ${sorted[0][0]} has ${sorted[0][1]} calories.` );

	var total = 0;
	for ( i in [ 0, 1, 2 ] ) {
		total += sorted[i][1];
	}
	console.log( `The top three elves have ${total} calories total.` );

} );
