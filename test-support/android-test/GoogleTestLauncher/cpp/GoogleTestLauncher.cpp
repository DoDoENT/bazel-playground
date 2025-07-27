#include <gtest/gtest.h>

#include <memory>
#include <vector>

#include <jni.h>

#include <android/asset_manager_jni.h>

#ifndef JNI_PREFIX
#error "Please define JNI_PREFIX"
#endif

//------------------------------------------------------------------------------
// JNI helper macros
//------------------------------------------------------------------------------

#define JNI_METHOD_HELPER1(prefix,name) Java_##prefix##_##name
#define JNI_METHOD_HELPER(prefix,name) JNI_METHOD_HELPER1(prefix,name)

#define JNI_METHOD( name ) JNI_METHOD_HELPER( JNI_PREFIX, name )


namespace GoogleTest
{

namespace
{
    AAssetManager * activeAssetManager{ nullptr };
}

AAssetManager * currentAssetManager()
{
    return activeAssetManager;
}

}

extern "C" JNIEXPORT jint JNICALL JNI_METHOD( invokeGoogleTest )( JNIEnv * env, jclass , jobjectArray args, jobject javaAssetManager )
{
    GoogleTest::activeAssetManager = AAssetManager_fromJava( env, javaAssetManager );

    jsize argCount = env->GetArrayLength( args );
    auto argv{ std::make_unique< char *[] >( argCount + 1 ) };

    std::vector< jstring > localRefs;
    localRefs.reserve( argCount );

    argv[ 0 ] = const_cast< char * >( "GoogleTestInvokerApp" );

    for ( jsize i{ 0 }; i < argCount; ++i )
    {
        jstring arg = static_cast< jstring >( env->GetObjectArrayElement( args, i ) );
        argv[ i + 1 ] = const_cast< char * >( env->GetStringUTFChars( arg, nullptr ) );
        localRefs.push_back( arg ); 
    }

    ::testing::InitGoogleTest( &argCount, argv.get() );
    auto result{ RUN_ALL_TESTS() };

    // cleanup memory
    for ( jsize i{ 0 }; i < argCount; ++i )
    {
        env->ReleaseStringUTFChars( localRefs[ i ], argv[ i + 1 ] );
        env->DeleteLocalRef( localRefs[ i ] );
    }

    GoogleTest::activeAssetManager = nullptr;

    return result;
}
