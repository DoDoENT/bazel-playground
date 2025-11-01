#include "PathProvider.hpp"

#include <android/asset_manager_jni.h>
#include <android/log.h>

#include <pthread.h>
#include <signal.h>
#include <unistd.h>

//------------------------------------------------------------------------------
namespace AndroidPaths
{
//------------------------------------------------------------------------------
namespace
{
    AAssetManager * assetManager    { nullptr };
    jobject         javaAssetManager{ nullptr };
    std::string     internalStorage;

    // redirect standard output and error streams to Android logcat
    // taken from: https://codelab.wordpress.com/2014/11/03/how-to-use-standard-output-streams-for-logging-in-android-apps/

    static int pfd[2];
    static pthread_t thr;
    static const char *tag = "ExeRunner";

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

AAssetManager * currentAssetManager()
{
    return assetManager;
}

std::string const & internalStoragePath()
{
    return internalStorage;
}

void initialize( JNIEnv * env, jobject jContext )
{
    jclass context = env->GetObjectClass( jContext );
    // obtain asset manager
    {
        jmethodID getAssets = env->GetMethodID( context, "getAssets", "()Landroid/content/res/AssetManager;" );
        jobject localAssetManager = env->CallObjectMethod( jContext, getAssets );
        javaAssetManager = env->NewGlobalRef( localAssetManager );
        assetManager = AAssetManager_fromJava( env, javaAssetManager );
    }
    // obtain internal storage path
    {
        jmethodID getFilesDir = env->GetMethodID( context, "getFilesDir", "()Ljava/io/File;" );
        jobject file = env->CallObjectMethod( jContext, getFilesDir );

        jclass fileClass = env->GetObjectClass( file );
        jmethodID getAbsolutePath = env->GetMethodID( fileClass, "getAbsolutePath", "()Ljava/lang/String;" );
        jstring absolutePath = static_cast< jstring >( env->CallObjectMethod( file, getAbsolutePath ) );

        char const * utf8Path = env->GetStringUTFChars( absolutePath, nullptr );

        internalStorage = utf8Path;

        env->ReleaseStringUTFChars( absolutePath, utf8Path );
    }
    startLogger( "ExeRunner" );
}

void terminate( JNIEnv * env )
{
    env->DeleteGlobalRef( javaAssetManager );

    javaAssetManager = nullptr;
    assetManager     = nullptr;
    internalStorage.clear();
}
//------------------------------------------------------------------------------
} // namespace AndroidPaths
//------------------------------------------------------------------------------
