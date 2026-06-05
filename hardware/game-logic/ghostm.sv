module ghostm(
    input logic vga_clk,
    input logic reset,
    input logic frame_clk,
    input logic freeze,
    input logic [9:0] pacmanX, pacmanY,
    input logic collision_up,
    input logic collision_down,
    input logic collision_left,
    input logic collision_right,
    output logic [9:0] ghostX, ghostY,
    output logic [1:0] ghost_direction,
    output logic ghost_collision_with_pacman
);
    parameter [9:0] GHOST_START_X=23;
    parameter [9:0] GHOST_START_Y=24;
    parameter SPEED=1;
    parameter [9:0] GHOST_SIZE=14;
    
    // synch collision signals
    logic collision_us, collision_ds, collision_ls, collision_rs;
    logic collision_u1, collision_d1, collision_l1, collision_r1;
    logic collision_u2, collision_d2, collision_l2, collision_r2;
    
    always_ff @(posedge frame_clk)
    begin
        if(reset)
        begin
            collision_u1<=1'b0;
            collision_d1<=1'b0;
            collision_l1<=1'b0;
            collision_r1<=1'b0;
            
            collision_u2<=1'b0;
            collision_d2<=1'b0;
            collision_l2<=1'b0;
            collision_r2<=1'b0;
            
            collision_us<=1'b0;
            collision_ds<=1'b0;
            collision_ls<=1'b0;
            collision_rs<=1'b0;
        end
        else
        begin
            collision_u1<=collision_up;
            collision_d1<=collision_down;
            collision_l1<=collision_left;
            collision_r1<=collision_right;
            
            collision_u2<=collision_u1;
            collision_d2<=collision_d1;
            collision_l2<=collision_l1;
            collision_r2<=collision_r1;
            
            collision_us<=collision_u2;
            collision_ds<=collision_d2;
            collision_ls<=collision_l2;
            collision_rs<=collision_r2;
        end
    end
    
    // set ghost speed
    logic [2:0] speed_cnt;
    logic move_enable;
    
    always_ff @(posedge frame_clk)
    begin
        if(reset)
            speed_cnt<=3'd0;
        else
        begin
            if(speed_cnt==3'd4)
                speed_cnt<=3'd0;
            else
                speed_cnt<=speed_cnt+3'd1;
        end
    end
    assign move_enable=(speed_cnt!=3'd4);
    
    // distance logic
    logic [9:0] dx,dy;
    always_comb
    begin
        dx=(pacmanX>=ghostX) ? (pacmanX-ghostX):(ghostX-pacmanX);
        dy=(pacmanY>=ghostY) ? (pacmanY-ghostY):(ghostY-pacmanY);
    end
    
    // direction logic
    parameter UP=2'b00;
    parameter DOWN=2'b01;
    parameter LEFT=2'b10;
    parameter RIGHT=2'b11;
    
    logic toward_right, toward_left, toward_down, toward_up;
    assign toward_right=(pacmanX>ghostX);
    assign toward_left=(pacmanX<ghostX);
    assign toward_down=(pacmanY>ghostY);
    assign toward_up=(pacmanY<ghostY);
    
    logic [1:0] c1, c2, c3, c4;
    always_comb
    begin
        if(dx>=dy)
        begin
            c1=toward_right ? RIGHT:LEFT;
            c2=toward_down ? DOWN:UP;
            c3=toward_down ? UP:DOWN;
            c4=toward_right ? LEFT:RIGHT;
        end
        else
        begin
            c1=toward_down ? DOWN:UP;
            c2=toward_right ? RIGHT:LEFT;
            c3=toward_right ? LEFT:RIGHT;
            c4=toward_down ? UP:DOWN;
        end
    end
    
    // next dir logic
    logic [1:0] next_dir;
    always_comb
    begin
        if(reset)
            next_dir=LEFT;
        else
        begin
            if(c1==UP && !collision_us)
                next_dir=UP;
            else if(c1==DOWN && !collision_ds)
                next_dir=DOWN;
            else if(c1==LEFT && !collision_ls)
                    next_dir=LEFT;
            else if(c1==RIGHT && !collision_rs)
                next_dir=RIGHT;
            
            else if(c2==UP && !collision_us)
                next_dir=UP;
            else if(c2==DOWN && !collision_ds)
                next_dir=DOWN;
            else if(c2==LEFT && !collision_ls)
                    next_dir=LEFT;
            else if(c2==RIGHT && !collision_rs)
                next_dir=RIGHT;
        
            else if(c3==UP && !collision_us)
                next_dir=UP;
            else if(c3==DOWN && !collision_ds)
                next_dir=DOWN;
            else if(c3==LEFT && !collision_ls)
                    next_dir=LEFT;
            else if(c3==RIGHT && !collision_rs)
                next_dir=RIGHT;
            
            else if(c4==UP && !collision_us)
                next_dir=UP;
            else if(c4==DOWN && !collision_ds)
                next_dir=DOWN;
            else if(c4==LEFT && !collision_ls)
                    next_dir=LEFT;
            else if(c4==RIGHT && !collision_rs)
                next_dir=RIGHT;
            else
                next_dir=ghost_direction;
        end
    end
    
    always_ff @(posedge frame_clk)
    begin
        if(reset)
        begin
            ghostX<=GHOST_START_X;
            ghostY<=GHOST_START_Y;
            ghost_direction<=LEFT;
        end
        else if(!freeze && move_enable)
        begin
            ghost_direction<=next_dir;
            case(next_dir)
                UP: ghostY<=ghostY-SPEED;
                DOWN: ghostY<=ghostY+SPEED;
                LEFT: ghostX<=ghostX-SPEED;
                RIGHT: ghostX<=ghostX+SPEED;
            endcase
        end
    end
    
    always_comb
    begin
        ghost_collision_with_pacman=(ghostX>=pacmanX-(GHOST_SIZE/2)) &&
                                    (ghostX<=pacmanX+(GHOST_SIZE/2)) &&
                                    (ghostY>=pacmanY-(GHOST_SIZE/2)) &&
                                    (ghostY<=pacmanY+(GHOST_SIZE/2));
    end
endmodule