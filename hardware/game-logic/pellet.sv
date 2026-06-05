module pellet(
    input logic vga_clk,
    input logic reset,
    input logic [9:0] DrawX, DrawY,
    input logic [9:0] pacmanX, pacmanY,
    input logic maze_on,
    input logic [3:0] maze_data,
    output logic pellet_on,
    output logic [3:0] pellet_red, pellet_green, pellet_blue,
    output logic pellet_eaten
);
    parameter BLOCK_SIZE=16;
    parameter PELLET_SIZE=1;
    parameter MAZE_WIDTH=480;
    parameter MAZE_HEIGHT=380;
    parameter GRID_COLS=MAZE_WIDTH/BLOCK_SIZE;
    parameter GRID_ROWS=MAZE_HEIGHT/BLOCK_SIZE;
    
    logic pellet_memory [0:GRID_ROWS-1][0:GRID_COLS-1];
    
    initial
    begin
        for(int i=0; i<GRID_ROWS; i++)
        begin
            for(int j=0; j<GRID_COLS; j++)
                pellet_memory[i][j]=1'b1;
        end
    end
    
    // find coordinates
    logic [5:0] blockX, blockY;
    logic valid_block;
    assign blockX=DrawX/BLOCK_SIZE;
    assign blockY=DrawY/BLOCK_SIZE;
    assign valid_block=(blockX<GRID_COLS)&&(blockY<GRID_ROWS) &&
                       (DrawX<MAZE_WIDTH)&&(DrawY<MAZE_HEIGHT);
    
    logic [9:0] centerX, centerY;
    assign centerX=(blockX*BLOCK_SIZE)+(BLOCK_SIZE/2);
    assign centerY=(blockY*BLOCK_SIZE)+(BLOCK_SIZE/2);
    
    logic pellet_pixel_on;
    assign pellet_pixel_on=valid_block && pellet_memory[blockY][blockX] &&
                           (DrawX>=centerX-PELLET_SIZE) &&
                           (DrawX<=centerX+PELLET_SIZE) &&
                           (DrawY>=centerY-PELLET_SIZE) &&
                           (DrawY<=centerY+PELLET_SIZE);

    // memory logic
    logic pellet_present;
    
    always_ff @(posedge vga_clk)
    begin
        pellet_eaten<=1'b0;
        
        if(reset)
        begin
            for(int i=0; i<GRID_ROWS; i++)
            begin
                for(int j=0; j<GRID_COLS; j++)
                    pellet_memory[i][j]<=1'b1;
            end
        end
        else
        begin
            // WRITTEN BY AI: pellet memory
            logic [5:0] pacman_blockX, pacman_blockY;
            pacman_blockX=pacmanX/BLOCK_SIZE;
            pacman_blockY=pacmanY/BLOCK_SIZE;
            
            if(pacman_blockX<GRID_COLS && pacman_blockY<GRID_ROWS &&
               pellet_memory[pacman_blockY][pacman_blockX])
            begin
                logic [9:0] pelletX, pelletY;
                pelletX=(pacman_blockX*BLOCK_SIZE)+(BLOCK_SIZE/2);
                pelletY=(pacman_blockY*BLOCK_SIZE)+(BLOCK_SIZE/2);
            // END OF AI
                if((pacmanX>=pelletX-8)&&(pacmanX<=pelletX+8) &&
                   (pacmanY>=pelletY-8)&&(pacmanY<=pelletY+8))
                begin
                    pellet_memory[pacman_blockY][pacman_blockX]<=1'b0;
                    pellet_eaten<=1'b1;
                end
            end
        end
    end
    
    assign pellet_on=pellet_pixel_on&&(maze_data==4'h0);
    assign pellet_red=pellet_on ? 4'hF:4'h0;
    assign pellet_green=pellet_on ? 4'hF:4'h0;
    assign pellet_blue=pellet_on ? 4'hF:4'h0;

endmodule