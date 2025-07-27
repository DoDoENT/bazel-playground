#pragma once

#include <memory>
#include <string>
#include <string_view>


std::string resolveTestDataPath( std::string_view relativePath );

struct FileBuffer
{
    std::unique_ptr< std::byte[] > data;
    std::size_t                    size{ 0 };
};

FileBuffer readFileToBuffer( std::string const & path );
