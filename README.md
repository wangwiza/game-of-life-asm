# Conway's Game of Life - ARMv7 Assembly Implementation

This project is an implementation of Conway's Game of Life, a cellular automaton, written in ARMv7 assembly language. The program simulates the evolution of a grid of cells based on predefined rules.

## Overview
Conway's Game of Life is a zero-player game in which the state of the board evolves over discrete time steps. Each cell on the board can either be alive or dead, and its state in the next generation is determined by the states of its eight neighbors.

### Rules of the Game
1. A live cell with fewer than two live neighbors dies (underpopulation).
2. A live cell with two or three live neighbors survives to the next generation.
3. A live cell with more than three live neighbors dies (overpopulation).
4. A dead cell with exactly three live neighbors becomes alive (reproduction).

## Features
- **Data Representation**: The grid is stored as a 2D array in memory, where each cell is represented by a single bit or word.
- **Initialization**: The program initializes the board with predefined patterns.
- **Neighbor Counting**: Efficient calculation of the number of live neighbors for each cell.
- **State Transition**: Updates the board based on Conway's rules.
- **Output**: Prints or updates the board to visualize the game progression.

## File Structure
- **Data Section**:
  - `GoLBoard`: Stores the current state of the game board.
  - `GoLNeighbours`: Temporary storage for neighbor counts.
- **Text Section**:
  - Functions to initialize the board and compute state transitions.
  - Game loop logic for iterating over generations.

## Getting Started
### Prerequisites
- ARMv7-compatible assembler and simulator/emulator (e.g., `qemu-arm` or an ARM development board).
- Basic knowledge of assembly programming.

### Building and Running
1. Assemble the program:
   ```bash
   as -o conway.o part3.s
   ld -o conway conway.o
   ```
2. Run the program:
   ```bash
   ./conway
   ```

### Example Initialization
The program includes an example board initialized in the `.data` section. You can modify this to test different patterns (e.g., gliders, blinkers, or still lifes).

## How It Works
### Core Functions
- **Initialization**: Sets up the initial game board with a predefined pattern.
- **Neighbor Calculation**: Iterates over each cell to calculate the number of live neighbors using efficient bitwise operations.
- **State Update**: Applies Conway's rules to transition the board to the next generation.

### Optimizations
- Uses ARM-specific instructions for efficient memory access and bit manipulation.
- Implements loops and conditions tailored for the ARM architecture.

## Customization
To modify the initial state of the board:
1. Open the `.data` section in the assembly file.
2. Update the `GoLBoard` array with your desired pattern.
3. Reassemble and run the program.

## Notes
- Ensure the board dimensions and initialization patterns fit within the memory constraints.
- The program assumes a fixed-size grid; extending it may require changes to the memory layout.

## License
This project is open-source. Feel free to use and modify it for educational purposes.

## Acknowledgments
Conway's Game of Life was devised by John Conway in 1970. This implementation showcases how classic algorithms can be translated into low-level assembly programming.

