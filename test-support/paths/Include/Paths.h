#pragma once

#include <memory>
#include <string>
#include <string_view>


std::string resolveTestDataPath( std::string_view relativePath ) MB_NOEXCEPT_EXCEPT_BADALLOC;
std::string resolveWriteableDirPath( std::string_view relativePath ) MB_NOEXCEPT_EXCEPT_BADALLOC;

struct FileBuffer
{
    std::unique_ptr< std::byte[] > data;
    std::size_t                    size{ 0 };
};

FileBuffer readFileToBuffer( std::string const & path ) MB_NOEXCEPT_EXCEPT_BADALLOC;
