module ghost_collision(
    input logic vga_clk,
    input logic [9:0] ghostX, ghostY,
    input logic [1:0] ghost_direction,
    output logic collision_with_wall
);

    parameter MAZE_WIDTH = 500;
    parameter MAZE_HEIGHT = 400;
    
    // Check points in front of ghost based on direction
    logic [9:0] check_x [2:0], check_y [2:0];
    logic [18:0] rom_addr [2:0];
    logic [3:0] rom_data [2:0];
    
    always_comb begin
        // Calculate check points based on ghost direction
        case (ghost_direction)
            2'b00: begin // UP
                for (int i = 0; i < 3; i++) begin
                    check_y[i] = (ghostY > 8) ? ghostY - 8 : 10'd0;
                end
                check_x[0] = (ghostX > 6) ? ghostX - 6 : 10'd0;
                check_x[1] = ghostX;
                check_x[2] = (ghostX < MAZE_WIDTH-6) ? ghostX + 6 : MAZE_WIDTH-1;
            end
            2'b01: begin // DOWN
                for (int i = 0; i < 3; i++) begin
                    check_y[i] = (ghostY < MAZE_HEIGHT-8) ? ghostY + 8 : MAZE_HEIGHT-1;
                end
                check_x[0] = (ghostX > 6) ? ghostX - 6 : 10'd0;
                check_x[1] = ghostX;
                check_x[2] = (ghostX < MAZE_WIDTH-6) ? ghostX + 6 : MAZE_WIDTH-1;
            end
            2'b10: begin // LEFT
                for (int i = 0; i < 3; i++) begin
                    check_x[i] = (ghostX > 8) ? ghostX - 8 : 10'd0;
                end
                check_y[0] = (ghostY > 6) ? ghostY - 6 : 10'd0;
                check_y[1] = ghostY;
                check_y[2] = (ghostY < MAZE_HEIGHT-6) ? ghostY + 6 : MAZE_HEIGHT-1;
            end
            2'b11: begin // RIGHT
                for (int i = 0; i < 3; i++) begin
                    check_x[i] = (ghostX < MAZE_WIDTH-8) ? ghostX + 8 : MAZE_WIDTH-1;
                end
                check_y[0] = (ghostY > 6) ? ghostY - 6 : 10'd0;
                check_y[1] = ghostY;
                check_y[2] = (ghostY < MAZE_HEIGHT-6) ? ghostY + 6 : MAZE_HEIGHT-1;
            end
        endcase
        
        // Calculate ROM addresses
        for (int i = 0; i < 3; i++) begin
            rom_addr[i] = check_y[i] * MAZE_WIDTH + check_x[i];
        end
    end
    
    // Wall collision if any of the 3 points hit a wall (non-zero color)
    assign collision_with_wall = (rom_data[0] != 4'h0) || 
                                (rom_data[1] != 4'h0) || 
                                (rom_data[2] != 4'h0);
    
    // ROM instances for collision detection
    maze_rom ghost_rom_0 (.clka(vga_clk), .addra(rom_addr[0]), .douta(rom_data[0]));
    maze_rom ghost_rom_1 (.clka(vga_clk), .addra(rom_addr[1]), .douta(rom_data[1]));
    maze_rom ghost_rom_2 (.clka(vga_clk), .addra(rom_addr[2]), .douta(rom_data[2]));

endmodule