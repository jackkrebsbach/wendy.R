CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 #Wall and Wextra catches errors, 02 helps optimize compile

SRC_DIR = ./pkg/src
BUILD_DIR = ./build

SOURCES = $(SRC_DIR)/index.cpp
TARGET = $(BUILD_DIR)/program

$(TARGET): $(SOURCES) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $^ -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean rebuild run

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	./$(TARGET)
