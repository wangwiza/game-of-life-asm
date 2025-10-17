# Conway's Game of Life in ARMv7 Assembly

A from-scratch implementation of Conway's Game of Life for ARMv7, featuring direct VGA output and PS/2 keyboard input for real-time, interactive cellular automata simulation.

-----

## 🎮 About The Project

This project brings Conway's classic zero-player game to life on bare-metal ARMv7 hardware. It's a testament to the power of low-level programming, written entirely in assembly language. The simulation runs on a 16x12 grid, displayed on a VGA monitor, and allows for real-time interaction through a connected PS/2 keyboard.

The core of the project is a set of optimized routines for drawing graphics, handling user input, and, of course, implementing the rules of the Game of Life.

-----

## ✨ Features

  * **VGA Graphics Driver**: Includes functions for drawing individual pixels, lines, and rectangles, as well as clearing the screen and writing characters.
  * **PS/2 Keyboard Driver**: A simple driver to read scancodes from a PS/2 keyboard, enabling user interaction.
  * **Interactive Grid**: A 16x12 grid is drawn on the screen where you can toggle cells on and off.
  * **Cursor Navigation**: Use the 'W', 'A', 'S', and 'D' keys to move a cursor around the grid.
  * **Cell Manipulation**: The 'SPACE' key flips the state of the cell under the cursor.
  * **Simulation Control**: The 'N' key advances the simulation to the next generation.

-----

## 🛠️ How It Works

The simulation is managed through a main loop that continuously checks for keyboard input. The state of the game is stored in two primary data structures: `GoLBoard` and `GoLNeighbours`.

  * `GoLBoard`: A 2D array representing the grid, where each entry is a word indicating whether a cell is alive or dead.
  * `GoLNeighbours`: A corresponding 2D array that stores the number of living neighbors for each cell. This is updated before each new generation is calculated.

The program's flow is as follows:

1.  **Initialization**: Clears the VGA screen, draws the grid, and displays the initial pattern from `GoLBoard`.
2.  **User Input**: The main loop polls the PS/2 keyboard for input.
3.  **Cursor Movement**: W, A, S, D keys update the cursor's position on the grid.
4.  **State Toggling**: The spacebar flips the state of the selected cell in `GoLBoard` and updates the `GoLNeighbours` board.
5.  **Generation Step**: Pressing 'N' triggers the update to the next generation:
      * The current screen is cleared.
      * `GoL_update_game_state_ASM` applies the rules of Conway's Game of Life to `GoLBoard` based on the counts in `GoLNeighbours`.
      * The new `GoLBoard` is drawn to the screen.
      * `GoL_update_neighbours_ASM` is called to prepare for the next step.

-----

## 🚀 Getting Started

To get this project running, you'll need an ARMv7 development environment.

### Prerequisites

  * An ARMv7 assembler (e.g., `as`) and linker (e.g., `ld`).
  * An ARMv7 simulator (like QEMU) or a physical development board with VGA and PS/2 ports.

### Building and Running

1.  **Assemble the code**:
    ```bash
    as -o game_of_life.o game_of_life.s
    ```
2.  **Link the object file**:
    ```bash
    ld -o game_of_life game_of_life.o
    ```
3.  **Run the executable**:
    ```bash
    ./game_of_life
    ```
    (Or load it onto your development board)

-----

## ⌨️ Controls

  * **W**: Move cursor up
  * **A**: Move cursor left
  * **S**: Move cursor down
  * **D**: Move cursor right
  * **SPACE**: Toggle the cell at the cursor's position (alive/dead)
  * **N**: Advance to the next generation

-----

## 🎨 Customization

The initial state of the Game of Life board can be easily customized.

1.  Open the `game_of_life.s` file.
2.  Navigate to the `.data` section.
3.  Modify the `GoLBoard` array with your desired starting pattern. A `1` represents a live cell, and a `0` represents a dead cell.
4.  Re-assemble and run the program to see your new pattern in action\!

-----

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
