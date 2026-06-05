module collision(
    input logic vga_clk,
    input logic [9:0] pacmanX, pacmanY,
    input logic [1:0] direction,
    input logic direction_changed,
    output logic collision,
    output logic [3:0] collision_directions
);
    parameter MAZE_WIDTH=480;
    parameter MAZE_HEIGHT=380;
    parameter ROM_WIDTH=320;
    parameter ROM_HEIGHT=256;
    
    // probe points
    logic [9:0] check_up_x [3:0], check_up_y [3:0];
    logic [9:0] check_down_x [3:0], check_down_y [3:0];
    logic [9:0] check_left_x [2:0], check_left_y [2:0];
    logic [9:0] check_right_x [2:0], check_right_y [2:0];
    
    always_comb
    begin
        for(int i=0; i<4; i++)
            check_up_y[i]=pacmanY-9;
        check_up_x[0]=pacmanX-8;
        check_up_x[1]=pacmanX-4;
        check_up_x[2]=pacmanX;
        check_up_x[3]=pacmanX+4;
    end
    
    always_comb
    begin
        for(int i=0; i<4; i++)
            check_down_y[i]=pacmanY+7;
        check_down_x[0]=pacmanX-8;
        check_down_x[1]=pacmanX-4;
        check_down_x[2]=pacmanX;
        check_down_x[3]=pacmanX+4;
    end
    
    always_comb
    begin
        for(int i=0; i<3; i++)
            check_left_x[i]=pacmanX-12;
        check_left_y[0]=pacmanY-4;
        check_left_y[1]=pacmanY;
        check_left_y[2]=pacmanY+4;
    end
    
    always_comb
    begin
        for(int i=0; i<3; i++)
            check_right_x[i]=pacmanX+6;
        check_right_y[0]=pacmanY-4;
        check_right_y[1]=pacmanY;
        check_right_y[2]=pacmanY+4;
    end
    
    // scale to ROM
    logic [9:0] up_x [3:0], up_y [3:0];
    logic [9:0] down_x [3:0], down_y [3:0];
    logic [9:0] left_x [2:0], left_y [2:0];
    logic [9:0] right_x [2:0], right_y [2:0];
    
    always_comb 
    begin
        for(int i=0; i<4; i++)
        begin   
            up_x[i]=(check_up_x[i]*ROM_WIDTH)/MAZE_WIDTH;
            up_y[i]=(check_up_y[i]*ROM_HEIGHT)/MAZE_HEIGHT;
            
            down_x[i]=(check_down_x[i]*ROM_WIDTH)/MAZE_WIDTH;
            down_y[i]=(check_down_y[i]*ROM_HEIGHT)/MAZE_HEIGHT;
            
            if(up_x[i]>=ROM_WIDTH)
                up_x[i]=ROM_WIDTH-1;
            if(down_x[i]>=ROM_WIDTH)
                down_x[i]=ROM_WIDTH-1;
            if(up_y[i]>=ROM_HEIGHT)
                up_y[i]=ROM_HEIGHT-1;
            if(down_y[i]>=ROM_HEIGHT)
                down_y[i]=ROM_HEIGHT-1;
        end
        
        for(int i=0; i<3; i++)
        begin   
            left_x[i]=(check_left_x[i]*ROM_WIDTH)/MAZE_WIDTH;
            left_y[i]=(check_left_y[i]*ROM_HEIGHT)/MAZE_HEIGHT;
            
            right_x[i]=(check_right_x[i]*ROM_WIDTH)/MAZE_WIDTH;
            right_y[i]=(check_right_y[i]*ROM_HEIGHT)/MAZE_HEIGHT;
            
            if(left_x[i]>=ROM_WIDTH)
                left_x[i]=ROM_WIDTH-1;
            if(right_x[i]>=ROM_WIDTH)
                right_x[i]=ROM_WIDTH-1;
            if(left_y[i]>=ROM_HEIGHT)
                left_y[i]=ROM_HEIGHT-1;
            if(right_y[i]>=ROM_HEIGHT)
                right_y[i]=ROM_HEIGHT-1;
        end
    end
    
    // ROM addresses
    logic [18:0] rom_addr_up [3:0];
    logic [18:0] rom_addr_down [3:0];
    logic [18:0] rom_addr_left [2:0];
    logic [18:0] rom_addr_right [2:0];
    
    // WRITTEN BY AI: ASSIGNING ROM ADDR
    generate
        for(genvar i=0; i<4; i++)
        begin
            assign rom_addr_up[i]=up_y[i]*ROM_WIDTH+up_x[i];
            assign rom_addr_down[i]=down_y[i]*ROM_WIDTH+down_x[i];
        end
        for(genvar i=0; i<3; i++)
        begin
            assign rom_addr_left[i]=left_y[i]*ROM_WIDTH+left_x[i];
            assign rom_addr_right[i]=right_y[i]*ROM_WIDTH+right_x[i];
        end
    endgenerate
    // END OF AI
    
    // FSM and ROM access
    logic [18:0] rom_address;
    logic [3:0] rom_data;
    
    logic [3:0] pixel_up [3:0];
    logic [3:0] pixel_down [3:0];
    logic [3:0] pixel_left [2:0];
    logic [3:0] pixel_right [2:0];
    
    logic [5:0] sample_counter;
    logic sampling_active;
    
    always_ff @(posedge vga_clk)
    begin
        if(direction_changed)
        begin
            sample_counter<=0;
            sampling_active<=1;
        end
        else if(!sampling_active)
        begin
            sample_counter<=0;
            sampling_active<=1;
            rom_address<=rom_addr_up[0];
        end
        else
        begin
            case(sample_counter)
            0:
            begin
                rom_address<=rom_addr_up[1];
                sample_counter<=1;
            end
            1:
                sample_counter<=2;
            2:
            begin
                pixel_up[0]<=rom_data;
                rom_address<=rom_addr_up[2];
                sample_counter<=3;
            end
            3:
                sample_counter<=4;
            4:
            begin
                pixel_up[1]<=rom_data;
                rom_address<=rom_addr_up[3];
                sample_counter<=5;
            end
            5:
                sample_counter<=6;
            6:
            begin
                pixel_up[2]<=rom_data;
                rom_address<=rom_addr_down[0];
                sample_counter<=7;
            end
            7:
                sample_counter<=8;
            8:
            begin
                pixel_up[3]<=rom_data;
                rom_address<=rom_addr_down[1];
                sample_counter<=9;
            end
            9:
                sample_counter<=10;
            10:
            begin
                pixel_down[0]<=rom_data;
                rom_address<=rom_addr_down[2];
                sample_counter<=11;
            end
            11:
                sample_counter<=12;
            12:
            begin
                pixel_down[1]<=rom_data;
                rom_address<=rom_addr_down[3];
                sample_counter<=13;
            end
            13:
                sample_counter<=14;
            14:
            begin
                pixel_down[2]<=rom_data;
                rom_address<=rom_addr_left[0];
                sample_counter<=15;
            end
            15:
                sample_counter<=16;
            16:
            begin
                pixel_down[3]<=rom_data;
                rom_address<=rom_addr_left[1];
                sample_counter<=17;
            end
            17:
                sample_counter<=18;
            18:
            begin
                pixel_left[0]<=rom_data;
                rom_address<=rom_addr_left[2];
                sample_counter<=19;
            end
            19:
                sample_counter<=20;
            20:
            begin
                pixel_left[1]<=rom_data;
                rom_address<=rom_addr_right[0];
                sample_counter<=21;
            end
            21:
                sample_counter<=22;
            22:
            begin
                pixel_left[2]<=rom_data;
                rom_address<=rom_addr_right[1];
                sample_counter<=23;
            end
            23:
                sample_counter<=24;
            24:
            begin
                pixel_right[0]<=rom_data;
                rom_address<=rom_addr_right[2];
                sample_counter<=25;
            end
            25:
                sample_counter<=26;
            26:
            begin
                pixel_right[1]<=rom_data;
                sample_counter<=27;
            end
            27:
                begin
                pixel_right[2]<=rom_data;
                sampling_active<=0;
                end
            endcase
        end
    end
    
    maze_rom maze_rom_collision(
        .clka(vga_clk),
        .addra(rom_address),
        .douta(rom_data)
    );
    
    logic collision_up_c=(pixel_up[0]==4'h1 ||
                          pixel_up[1]==4'h1 ||
                          pixel_up[2]==4'h1 ||
                          pixel_up[3]==4'h1);
    logic collision_down_c=(pixel_down[0]==4'h1 ||
                          pixel_down[1]==4'h1 ||
                          pixel_down[2]==4'h1 ||
                          pixel_down[3]==4'h1);
    logic collision_left_c=(pixel_left[0]==4'h1 ||
                          pixel_left[1]==4'h1 ||
                          pixel_left[2]==4'h1);
    logic collision_right_c=(pixel_right[0]==4'h1 ||
                          pixel_right[1]==4'h1 ||
                          pixel_right[2]==4'h1);
                          
    assign collision_directions={collision_up_c,
                                 collision_down_c,
                                 collision_left_c,
                                 collision_right_c};
    always_comb
    begin
        collision=1'b0;
        case(direction)
            2'b00: collision=collision_up_c;
            2'b01: collision=collision_down_c;
            2'b10: collision=collision_left_c;
            2'b11: collision=collision_right_c;
        endcase
    end
endmodule