#include "BundlePathProvider.hpp"
#include "macros/ios-helpers/BundlePathProviderSwift-Swift.h"

namespace IosBundlePath
{

std::string currentBundlePath()
{
    return std::string{ BundlePathProviderSwift::currentBundlePath() };
}

std::string currentOutputDirPath()
{
    return std::string{ BundlePathProviderSwift::currentOutputDirPath() };
}

}
