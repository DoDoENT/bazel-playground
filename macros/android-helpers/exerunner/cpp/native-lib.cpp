#if __has_include(<CoreUtils/Android/Application.hpp>)
#   include <CoreUtils/Android/Application.hpp>
#   define MB_HAS_COREUTILS_ANDROID_APPLICATION 1
#endif

#include <PathProviderInternal.hpp>

#include <cstdlib>
#include <string>
#include <vector>

#include <jni.h>

extern int main( int argc, char** argv );

extern "C" {

JNIEXPORT void JNICALL
Java_com_example_exerunner_NativeRunner_initialize( JNIEnv * env, jclass, jobject jContext )
{
    AndroidPaths::startLogger( "ExeRunner" );

#if MB_HAS_COREUTILS_ANDROID_APPLICATION
    MB::Android::initializeApplication( env, jContext );
#else
    AndroidPaths::initialize( env, jContext );
#endif
}

JNIEXPORT void JNICALL
Java_com_example_exerunner_NativeRunner_terminate( [[ maybe_unused ]] JNIEnv * env, jclass )
{
#if MB_HAS_COREUTILS_ANDROID_APPLICATION
    MB::Android::terminateApplication();
#else
    AndroidPaths::terminate( env );
#endif
}

JNIEXPORT void JNICALL
Java_com_example_exerunner_NativeRunner_interrupt( JNIEnv*, jclass ) {
    raise( SIGINT );
}

JNIEXPORT jint JNICALL
Java_com_example_exerunner_NativeRunner_runNative( JNIEnv* env, jclass, jstring commandLineParams )
{
    const char* command_line_params = env->GetStringUTFChars( commandLineParams, 0 );

    std::vector< std::string > parameters;
    parameters.push_back( "dummy_exe_name" );

    std::size_t begin = 0;
    std::size_t end = begin;
    bool in_quotes = false;

    while( command_line_params[ end ] != 0 ) {
        if( command_line_params[ end ] == '\"' ) {
            in_quotes = !in_quotes;
        } else if( command_line_params[ end ] == ' ' && !in_quotes ) {
            if( begin < end ) {
                // if parameter both starts and ends with quotes, omit them
                auto param_begin = begin;
                auto param_end = end;
                if( command_line_params[ param_begin ] == '\"' && command_line_params[ param_end - 1 ] == '\"' ) {
                    ++param_begin;
                    --param_end;
                }
                parameters.emplace_back( command_line_params + param_begin, param_end - param_begin );
            }
            // search for next non-space
            while( command_line_params[ end ] == ' ' && command_line_params[ end ] != 0 ) ++end;
            begin = end;
            continue; // skip end increment below
        }
        ++end;
    }
    if( begin < end ) {
        parameters.emplace_back( command_line_params + begin, end - begin );
    }

    const char** argv = ( const char** ) std::calloc( parameters.size() + 1, sizeof( const char * ) );
    for( auto i = 0U; i < parameters.size(); ++i ) {
        argv[ i ] = parameters[ i ].c_str();
    }

    int exit_status = main( static_cast< int >( parameters.size() ), const_cast< char** >( argv ) );

    std::free( argv );

    env->ReleaseStringUTFChars( commandLineParams, command_line_params );

    return exit_status;
}

}
