CXX = clang++
R_HOME = /opt/homebrew
RSCRIPT = $(R_HOME)/bin/Rscript
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -fPIC -w -I/opt/homebrew/include \
			$(shell $(RSCRIPT) -e "Rcpp:::CxxFlags()")
LDFLAGS = -L/opt/homebrew/lib \
		$(shell $(RSCRIPT) -e "Rcpp:::LdFlags()")
LIBS = -lsymengine -lflint -lgmp -lmpfr -lR


TARGET = test_symbolic_utils
SRC = test_symbolic_utils.cpp ../core/symbolic_utils.cpp

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
