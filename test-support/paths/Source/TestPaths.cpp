
#include <TestPaths/TestPaths.hpp>

#include <cassert>
#include <cstdio>
#include <cstdint>

#include <sys/stat.h>

#ifdef __ANDROID__
#include <android/asset_manager.h>
#endif

#if __APPLE__
#include <TargetConditionals.h>
#endif

#if TARGET_OS_IPHONE
// will be defined in the google test ios invoker library
namespace GoogleTest
{
    std::string currentBundlePath();
}
#endif

#ifdef __ANDROID__
// will be defined in the google test android invoker library
namespace GoogleTest
{
    AAssetManager * currentAssetManager();
}

#endif

std::string resolveTestDataPath( std::string_view relativePath )
{
#if TARGET_OS_IPHONE
    auto prefix{ GoogleTest::currentBundlePath() + "/" };
#else
    constexpr auto prefix{ "" };
#endif
    return prefix + std::string{ "test-data/" } + std::string{ relativePath };
}

namespace
{
    using FilePtr = std::unique_ptr< FILE, decltype( &std::fclose ) >;

    inline FilePtr openFile( std::string const & path )
    {
        return
        {
            std::fopen( path.c_str(), "rb" ),
            &std::fclose
        };
    }

    std::uint64_t fileGetLength( FILE * const file ) noexcept
    {
        // https://wiki.sei.cmu.edu/confluence/display/c/FIO19-C.+Do+not+use+fseek%28%29+and+ftell%28%29+to+compute+the+size+of+a+regular+file
        auto const fileDescriptor( ::fileno( file ) );
        assert( fileDescriptor != -1 );
        struct ::stat info;
        [[ maybe_unused ]] auto result{ ::fstat( fileDescriptor, &info ) };
        assert( result == 0 );
        assert( info.st_mode & S_IFREG );
        return static_cast< std::uint64_t >( info.st_size );
    }
}

FileBuffer readFileToBuffer( std::string const & filePath )
{
    FilePtr file { openFile( filePath ) };
    if ( file == nullptr )
    {
#ifdef __ANDROID__
        auto * assetManager{ GoogleTest::currentAssetManager() };
        if ( assetManager != nullptr )
        {
            std::unique_ptr< AAsset, decltype( &AAsset_close ) > asset
            {
                AAssetManager_open( assetManager, filePath.c_str(), AASSET_MODE_STREAMING ),
                &AAsset_close
            };
            // some use cases expect this behaviour (e.g., Recognizer Tests)
            if ( asset == nullptr ) return {};

            auto size = std::size_t( AAsset_getLength( asset.get() ) );
            assert( size > 0 );

            /// \note use one byte more to be able to append zero in case
            ///       file is text file (this function is also used to load text/json files
            ///       in various tests). However, report final buffer size as exactly the
            ///       size of file.
            auto bufferLength{ size + 1 };

            auto fileBuffer = std::make_unique< std::byte[] >( bufferLength );
            fileBuffer[ size ] = static_cast< std::byte >( 0 );

            auto bytesRead{ AAsset_read( asset.get(), fileBuffer.get(), size ) };

            if ( bytesRead > 0 )
            {
                return
                {
                    .data = std::move( fileBuffer ),
                    .size = std::size_t( bytesRead )
                };
            }
            else
            {
                return {};
            }
        }
        else
        {
            return {};
        }
#else
        return {};
#endif
    }

    auto const fileLength( static_cast< std::size_t >( fileGetLength( file.get() ) ) );

    /** @note
     * use one byte more to be able to append zero in case
     * file is text file (this function is also used to load text/json files
     * in various tests). However, report final buffer size as exactly the
     * size of file.
     */
    std::size_t bufferLength = fileLength + 1;

    std::unique_ptr< std::byte[] > fileBuffer{ new std::byte[ bufferLength ] };
    fileBuffer[ fileLength ] = static_cast< std::byte >( 0 );

    auto bytesRead{ std::fread( fileBuffer.get(), 1, fileLength, file.get() ) };

    if ( bytesRead > 0 )
    {
        return
        {
            .data = std::move( fileBuffer ),
            .size = static_cast< std::size_t >( bytesRead )
        };
    }
    else
    {
        return {};
    }
}
