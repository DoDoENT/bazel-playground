var mb_emrun_http_sequence_number = 1;

var mb_post = ( msg ) => {
    var http = new XMLHttpRequest();
    http.open( "POST", "stdio.html", false );
    http.send( msg );
};

Module[ "print" ] = ( text ) => {
    console.log( text );
    mb_post( '^out^' + ( mb_emrun_http_sequence_number++ ) + '^' + encodeURIComponent( text ) );
    postMessage( text );
};
Module[ "printErr" ] = ( text ) => {
    console.error( text );
    mb_post( '^err^' + ( mb_emrun_http_sequence_number++ ) + '^' + encodeURIComponent( text ) );
    postMessage( "ERROR: " + text );
};
Module[ "postRun" ] = () => {
    console.log( "FINISHED, exit status: ", EXITSTATUS );
    mb_post( '^exit^' + EXITSTATUS );
    postMessage( "^exit^" + EXITSTATUS );
    // must not close the runtime or the last crash events won't be correctly dispatched
    // self.close();
};
Module[ "setStatus" ] = ( text ) => {
    console.log( "Status: ", text );
};
Module[ "onAbort" ] = function( text ) {
    // don't rely on stacktrace function that sometimes does not exist, depending on the version of emscripten
    // always use the trick from here: https://code-maven.com/stack-trace-in-javascript
    try {
        var e = new WebAssembly.RuntimeError( text );
        throw e;
    } catch ( exc ) {
        err( "Stacktrace: " + exc.stack );
    }
    mb_post( '^exit^' + EXITSTATUS );
    postMessage( "^exit^" + EXITSTATUS );
};

const searchParams = new URLSearchParams( self.location.search );
Module[ "arguments" ] = Array.from( searchParams.keys() );
