
#if defined( __EMSCRIPTEN__ ) && defined( __EMSCRIPTEN_PTHREADS__ )
#include <emscripten.h>

#include <algorithm>

namespace
{
    EM_JS
    (
        int, allowedNumberOfThreads, (),
        {
            return navigator['hardwareConcurrency'];
        }
    )
}

#ifndef EMSCRIPTEN_EMRUN_MAX_NUMBER_OF_WORKERS
#define EMSCRIPTEN_EMRUN_MAX_NUMBER_OF_WORKERS 16
#endif

extern "C"
{

// override the default function with the custom one
int emscripten_num_logical_cores()
{
    // most browsers cause problems if too may workers are created
    // there is no specific maximum, but chrome deadlocks if number of workers is larger than 32
    // For most of our use cases, this number of workers should be enough
    // NOTE: need to update this constant also in wasmthreadhelper.js
    constexpr auto maxAllowedWorkers{  EMSCRIPTEN_EMRUN_MAX_NUMBER_OF_WORKERS };
    return std::min( allowedNumberOfThreads(), maxAllowedWorkers );
}

}
#endif
