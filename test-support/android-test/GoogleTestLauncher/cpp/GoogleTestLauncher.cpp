
#if __has_include(<CoreUtils/Android/Application.hpp>)
#include <CoreUtils/Android/Application.hpp>
#define MB_HAS_COREUTILS_ANDROID_APPLICATION 1
#endif

#include <PathProviderInternal.hpp>

#include <gtest/gtest.h>

#include <memory>
#include <vector>

#include <jni.h>

#include <android/asset_manager_jni.h>
#include <android/log.h>

#define JNI_PREFIX com_example_testrunner_GoogleTestLauncher

//------------------------------------------------------------------------------
// JNI helper macros
//------------------------------------------------------------------------------

#define JNI_METHOD_HELPER1(prefix,name) Java_##prefix##_##name
#define JNI_METHOD_HELPER(prefix,name) JNI_METHOD_HELPER1(prefix,name)

#define JNI_METHOD( name ) JNI_METHOD_HELPER( JNI_PREFIX, name )

namespace
{
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

extern "C" JNIEXPORT jint JNICALL JNI_METHOD( invokeGoogleTest )( JNIEnv * env, jclass , jobjectArray args, jobject jGTestListener, jobject jContext )
{
    AndroidPaths::startLogger( "GoogleTestLauncher" );

#if MB_HAS_COREUTILS_ANDROID_APPLICATION
    MB::Android::initializeApplication( env, jContext );
#endif

    AndroidPaths::initialize( env, jContext );

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

    GTestListener listener( env, jGTestListener );
    testing::UnitTest * googleTest = testing::UnitTest::GetInstance();

    googleTest->listeners().Append( &listener );

    auto result{ RUN_ALL_TESTS() };

    // cleanup memory
    for ( jsize i{ 0 }; i < argCount - 1; ++i )
    {
        env->ReleaseStringUTFChars( localRefs[ static_cast< std::size_t >( i ) ], argv[ static_cast< std::size_t >( i + 1 ) ] );
        env->DeleteLocalRef( localRefs[ static_cast< std::size_t >( i ) ] );
    }

#if MB_HAS_COREUTILS_ANDROID_APPLICATION
    MB::Android::terminateApplication();
#endif

    AndroidPaths::terminate( env );

    return result;
}
