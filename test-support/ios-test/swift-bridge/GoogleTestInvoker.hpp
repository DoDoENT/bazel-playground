#pragma once

#include <string>
#include <vector>

namespace GoogleTest
{

using ArgVector = std::vector<std::string>;

int executeGoogleTests( ArgVector const & args );

std::string currentBundlePath();
std::string currentOutputDirPath();
}
