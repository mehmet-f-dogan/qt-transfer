cmake_minimum_required(VERSION 3.16)
project(QtTransferApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)   # enable moc
set(CMAKE_AUTORCC ON)   # enable resources (.qrc)
set(CMAKE_AUTOUIC ON)   # enable .ui files

if(NOT DEFINED Qt6_DIR)
    if(WIN32)
        if(DEFINED ENV{Qt6_DIR})
            set(Qt6_DIR $ENV{Qt6_DIR})
        else()
            # Fallback: default Windows path — adjust if your Qt install differs
            set(Qt6_DIR "C:/Qt/6.10.2/mingw_64/lib/cmake/Qt6")
        endif()
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Network
    QuickControls2
    QuickDialogs2
)

qt_add_executable(app
    src/main.cpp
    src/protocol/IProtocol.cpp
    src/protocol/TcpProtocol.cpp
    src/protocol/UdpProtocol.cpp
    src/service/TransferService.cpp
    src/viewmodel/TransferViewModel.cpp
    src/resources.qrc
)

target_include_directories(app PRIVATE src)

target_link_libraries(app PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Network
    Qt6::QuickControls2
    Qt6::QuickDialogs2
)

set_target_properties(app PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)