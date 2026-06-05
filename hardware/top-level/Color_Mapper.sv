module  color_mapper ( input  logic [9:0] pacmanX, pacmanY, drawX, drawY, pacmanS,
                       input logic [15:0] pacman_rom_data,
                       output logic [7:0] pacman_rom_addr,
                       input logic [15:0] ghost_rom_data,
                       output logic [7:0] ghost_rom_addr,
                       output logic [3:0]  Red, Green, Blue );
    
    logic pacman_on, ghost_on;
    logic [9:0] spriteX, spriteY;
	 
    assign spriteX=drawX-pacmanX+8;
    assign spriteY=drawY-pacmanY+8;
    assign pacman_rom_addr=spriteY[7:0];
    
    logic [3:0] spriteP;
    assign spriteP=pacman_rom_data[15-spriteX[3:0]];
    
    // pacman display logic
    always_comb
    begin
        if(spriteX<16 && spriteY<16 && spriteP!=0)
            pacman_on=1'b1;
        else
        begin
            int distX, distY, size;
            distX=drawX-pacmanX;
            distY=drawY-pacmanY;
            size=pacmanS;
            pacman_on=((distX*distX+distY*distY)<=(size*size));
        end
    end
    
    // ghost display logic
    assign ghost_on=1'b0;
    
    // color selection
    always_comb
    begin
        if(pacman_on)
        begin
            if(spriteP!=0)
            begin
                Red=4'hF;
                Green=4'hF;
                Blue=4'h0;
            end
            else
            begin
                Red=4'hF;
                Green=4'h7;
                Blue=4'h0;
            end
        end  
        else
        begin
            Red=4'hF-drawX[9:6];
            Green=4'hF-drawX[9:6];
            Blue=4'hF-drawX[9:6];
        end    
    end 
endmodule
