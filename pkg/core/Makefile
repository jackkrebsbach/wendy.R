CXX = clang++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -fPIC
INCLUDE_DIR = /opt/homebrew/include
LIB_DIR = /opt/homebrew/lib
LIBS = -lsymengine -lflint -lgmp -lmpfr

SRC = core.cpp 
OBJ = $(SRC:.cpp=.o)
LIB = corelib.a

all: $(LIB)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -I$(INCLUDE_DIR) -c $< -o $@

$(LIB): $(OBJ)
	ar rcs $@ $^

clean:
	rm -f $(OBJ) $(LIB)
