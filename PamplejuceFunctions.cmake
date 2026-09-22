# One include() that defines all pamplejuce_* functions for you to call explicitly.
# The other .cmake files here stay separate includes: they have include-time behavior
# that must happen either before project() (PamplejuceVersion, PamplejuceMacOS) or
# after specific targets exist (PamplejuceIPP, GitHubENV).
#
# include() this after project(): Tests.cmake fetches Catch2 at include time.
set(_PAMPLEJUCE_USE_FUNCTIONS ON)

include("${CMAKE_CURRENT_LIST_DIR}/SharedCodeDefaults.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Assets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/XcodePrettify.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Tests.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Benchmarks.cmake")
