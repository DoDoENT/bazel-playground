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
