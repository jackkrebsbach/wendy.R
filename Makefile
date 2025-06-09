CXX = clang++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 # Wall Wextra 02 compiler arguments
INCLUDE_DIR = /opt/homebrew/include # Where the libraries are
LIB_DIR = /opt/homebrew/lib
LIBS = -lsymengine -lflint -lgmp -lmpfr # Need lflint lgmp and lmpfr to work with symengine

SRC_DIR = ./pkg/src
BUILD_DIR = ./build

SOURCES = $(SRC_DIR)/index.cpp
TARGET = $(BUILD_DIR)/program

all: $(TARGET)

$(TARGET): $(SOURCES) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -I$(INCLUDE_DIR) -L$(LIB_DIR) $^ -o $@ $(LIBS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean rebuild run

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	./$(TARGET)
