const shardPrefix = "--bazel-shard=";
const shardArgument = Module[ "arguments" ].find( ( argument ) => argument.startsWith( shardPrefix ) );
if ( shardArgument !== undefined ) {
    Module[ "arguments" ] = Module[ "arguments" ].filter( ( argument ) => argument !== shardArgument );
}
Module[ "preRun" ] = Module[ "preRun" ] || [];
Module[ "preRun" ].push( () => {
    if ( shardArgument !== undefined ) {
        const [ total, index ] = shardArgument.slice( shardPrefix.length ).split( "," );
        ENV[ "TEST_TOTAL_SHARDS" ] = total;
        ENV[ "TEST_SHARD_INDEX" ] = index;
        ENV[ "GTEST_TOTAL_SHARDS" ] = total;
        ENV[ "GTEST_SHARD_INDEX" ] = index;
    }
    Module[ "print" ]( "BAZEL_SHARDING_READY" );
} );
