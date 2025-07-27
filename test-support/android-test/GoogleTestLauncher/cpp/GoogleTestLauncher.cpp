#include <gtest/gtest.h>

#include <memory>
#include <vector>

#include <jni.h>

extern "C" JNIEXPORT jint JNICALL
Java_com_example_app_GoogleTestLauncher_invokeGoogleTest ( JNIEnv * env, jclass , jobjectArray args )
{
    jsize argCount = env->GetArrayLength( args );
    auto argv{ std::make_unique< char *[] >( argCount ) };

    std::vector< jstring > localRefs;
    localRefs.reserve( argCount );

    for ( jsize i{ 0 }; i < argCount; ++i )
    {
        jstring arg = static_cast< jstring >( env->GetObjectArrayElement( args, i ) );
        argv[ i ] = const_cast< char * >( env->GetStringUTFChars( arg, nullptr ) );
        localRefs.push_back( arg ); 
    }

    ::testing::InitGoogleTest( &argCount, argv.get() );
    auto result{ RUN_ALL_TESTS() };

    // cleanup memory
    for ( jsize i{ 0 }; i < argCount; ++i )
    {
        env->ReleaseStringUTFChars( localRefs[ i ], argv[ i ] );
        env->DeleteLocalRef( localRefs[ i ] );
    }

    return result;
}
