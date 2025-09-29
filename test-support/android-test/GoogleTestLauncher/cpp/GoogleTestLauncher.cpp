#include <gtest/gtest.h>

#include <memory>
#include <vector>

#include <jni.h>

#include <android/asset_manager_jni.h>
#include <android/log.h>

#ifndef JNI_PREFIX
#error "Please define JNI_PREFIX"
#endif

//------------------------------------------------------------------------------
// JNI helper macros
//------------------------------------------------------------------------------

#define JNI_METHOD_HELPER1(prefix,name) Java_##prefix##_##name
#define JNI_METHOD_HELPER(prefix,name) JNI_METHOD_HELPER1(prefix,name)

#define JNI_METHOD( name ) JNI_METHOD_HELPER( JNI_PREFIX, name )

//------------------------------------------------------------------------------
namespace GoogleTest
{
//------------------------------------------------------------------------------

namespace
{
    AAssetManager * activeAssetManager{ nullptr };
    std::string     internalStorage;

    class GTestListener : public ::testing::EmptyTestEventListener
    {
    public:
        GTestListener( JNIEnv * env, jobject jGTestListener ) :
            env_( env ),
            jGTestListener_( jGTestListener )
        {
            jclass listenerClass = env_->GetObjectClass( jGTestListener_ );
            onTestPartResult_ = env_->GetMethodID( listenerClass, "onTestPartResult", "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V" );
        }

        void OnTestPartResult( ::testing::TestPartResult const & testPartResult )
        {
            bool passed = testPartResult.passed();
            int lineNumber = testPartResult.line_number();
            char const * fileName = testPartResult.file_name();
            char const * message = testPartResult.message();
            char const * summary = testPartResult.summary();
            jstring jFileName = env_->NewStringUTF( fileName );
            jstring jMessage  = env_->NewStringUTF( message  );
            jstring jSummary  = env_->NewStringUTF( summary  );
            env_->CallVoidMethod
            (
                jGTestListener_,
                onTestPartResult_,
                static_cast< jboolean >( passed     ),
                static_cast< jint     >( lineNumber ),
                jFileName,
                jMessage,
                jSummary
            );
            env_->DeleteLocalRef( jFileName );
            env_->DeleteLocalRef( jMessage  );
            env_->DeleteLocalRef( jSummary  );
        }
    private:
        JNIEnv * env_;
        jobject jGTestListener_;
        jmethodID  onTestPartResult_;
    };
}

AAssetManager * currentAssetManager()
{
    return activeAssetManager;
}

std::string const & internalStoragePath()
{
    return internalStorage;
}

//------------------------------------------------------------------------------
} // namespace GoogleTest
//------------------------------------------------------------------------------

namespace
{
    // redirect standard output and error streams to Android logcat
    // taken from: https://codelab.wordpress.com/2014/11/03/how-to-use-standard-output-streams-for-logging-in-android-apps/

    static int pfd[2];
    static pthread_t thr;
    static const char *tag = "GoogleTestLauncher";

    static void * threadFunc( void * )
    {
        ssize_t rdsz;
        char buf[ 128];
        while( ( rdsz = read(pfd[0], buf, sizeof buf - 1) ) > 0 )
        {
            if( buf[ rdsz - 1 ] == '\n' ) --rdsz;
            buf[ rdsz ] = 0;  /* add null-terminator */
            __android_log_write( ANDROID_LOG_INFO, tag, buf );
        }
        return 0;
    }

    int startLogger( char const * app_name )
    {
        tag = app_name;

        /* make stdout line-buffered and stderr unbuffered */
        setvbuf( stdout, 0, _IOLBF, 0 );
        setvbuf( stderr, 0, _IONBF, 0 );

        /* create the pipe and redirect stdout and stderr */
        pipe( pfd );
        dup2( pfd[ 1 ], 1 );
        dup2( pfd[ 1 ], 2 );

        /* spawn the logging thread */
        if( pthread_create( &thr, 0, threadFunc, 0 ) == -1 )
            return -1;
        pthread_detach(thr);
        return 0;
    }
}

extern "C" JNIEXPORT jint JNICALL JNI_METHOD( invokeGoogleTest )( JNIEnv * env, jclass , jobjectArray args, jobject javaAssetManager, jstring jFilesDir, jobject jGTestListener )
{
    startLogger( "GoogleTestLauncher" );

    GoogleTest::activeAssetManager = AAssetManager_fromJava( env, javaAssetManager );

    // obtain internal storage path
    {
        char const * utf8Path = env->GetStringUTFChars( jFilesDir, nullptr );

        GoogleTest::internalStorage = utf8Path;

        env->ReleaseStringUTFChars( jFilesDir, utf8Path );
    }

    jsize argCount = 1 + env->GetArrayLength( args );
    auto argv{ std::make_unique< char *[] >( static_cast< std::size_t >( argCount + 1 ) ) };

    std::vector< jstring > localRefs;
    localRefs.reserve( static_cast< std::size_t >( argCount ) );

    argv[ 0 ] = const_cast< char * >( "GoogleTestLauncher" );

    for ( jsize i{ 0 }; i < argCount - 1; ++i )
    {
        jstring arg = static_cast< jstring >( env->GetObjectArrayElement( args, i ) );
        argv[ static_cast< std::size_t >( i + 1 ) ] = const_cast< char * >( env->GetStringUTFChars( arg, nullptr ) );
        localRefs.push_back( arg ); 
    }

    ::testing::InitGoogleTest( &argCount, argv.get() );

    GoogleTest::GTestListener listener( env, jGTestListener );
    testing::UnitTest * googleTest = testing::UnitTest::GetInstance();

    googleTest->listeners().Append( &listener );

    auto result{ RUN_ALL_TESTS() };

    // cleanup memory
    for ( jsize i{ 0 }; i < argCount - 1; ++i )
    {
        env->ReleaseStringUTFChars( localRefs[ static_cast< std::size_t >( i ) ], argv[ static_cast< std::size_t >( i + 1 ) ] );
        env->DeleteLocalRef( localRefs[ static_cast< std::size_t >( i ) ] );
    }

    GoogleTest::activeAssetManager = nullptr;

    return result;
}
