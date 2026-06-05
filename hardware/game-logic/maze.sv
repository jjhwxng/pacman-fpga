module  maze 
( 
    input logic        frame_clk,
    input logic [9:0]  drawX, drawY,
    input logic [9:0]   pacmanX, pacmanY,
    output logic        wall_collision,
    output logic [3:0]  maze_red, maze_green, maze_blue
);

// maze local parameters
parameter CELL_SIZE=40;
parameter MAZE_WIDTH=16;
parameter MAZE_HEIGHT=12;

// Maze layout: 1 = wall, 0 = path/pellet
// Each bit represents a 2x2 block (2 rows and 2 columns)
logic [0:MAZE_WIDTH-1] maze_layout [0:MAZE_HEIGHT-1] = '{
    'b1111111111111111, // Row 0-? (depends on how many rows map to 40px)
    'b1000000000000001,
    'b1011111111111101,
    'b1011111111111101,
    'b1000000000000001,
    'b1011111111111101,
    'b1011111111111101,
    'b1000000000000001,
    'b1011111111111101,
    'b1011111111111101,
    'b1000000000000001,
    'b1111111111111111
};

// convert pixels to maze coordinates
logic [5:0] mazeX, mazeY;
assign mazeX=drawX/CELL_SIZE;
assign mazeY=drawY/CELL_SIZE;

// convert pacman position to maze coordinates
logic [5:0] pacman_mazeX, pacman_mazeY;
assign pacman_mazeX=pacmanX/CELL_SIZE;
assign pacman_mazeY=pacmanY/CELL_SIZE;

// maze rendering logic
always_comb
begin
    if(mazeX<MAZE_WIDTH && mazeY<MAZE_HEIGHT)
    begin
        if(maze_layout[mazeY][mazeX]==1'b1)
        begin
            // draw wall
            maze_red=4'h0;
            maze_green=4'h0;
            maze_blue=4'hF;
        end
        else
        begin
            logic [9:0] cellX, cellY;
            logic [9:0] distX, distY;
            
            cellX=(mazeX*CELL_SIZE)+(CELL_SIZE/2);
            cellY=(mazeY*CELL_SIZE)+(CELL_SIZE/2);
            distX=(drawX>cellX) ? (drawX-cellX):(cellX-drawX);
            distY=(drawY>cellY) ? (drawY-cellY):(cellY-drawY);
            
            if(distX<2 && distY<2)
            begin
                // draw pellet
                maze_red=4'hF;
                maze_green=4'hF;
                maze_blue=4'hF;
            end
            else
            begin
                // draw path
                maze_red=4'h0;
                maze_green=4'h0;
                maze_blue=4'h0;
            end
        end
    end
    else
    begin
        maze_red=4'h0;
        maze_green=4'h0;
        maze_blue=4'h0;
    end
end

always_ff @(posedge frame_clk)
begin
    if(pacman_mazeX<MAZE_WIDTH && pacman_mazeY<MAZE_HEIGHT)
    begin
        wall_collision=(maze_layout[pacman_mazeY][pacman_mazeX]==1'b1);
    end
    else
        wall_collision=1'b1;
end
endmodule
