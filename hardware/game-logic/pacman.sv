module pacman(
    input logic Reset,
    input logic frame_clk,
    input logic [7:0] keycode,
    input logic collision,
    input logic freeze,
    output logic [9:0] pacmanX,
    output logic [9:0] pacmanY,
    output logic [1:0] direction,
    output logic direction_changed
);
    parameter [9:0] pacmanX_start=26;
    parameter [9:0] pacmanY_start=360;
    
    // motion variables
    logic [9:0] pacmanX_motion, pacmanY_motion;
    logic [9:0] pacmanX_motion_next, pacmanY_motion_next;
    logic [9:0] pacmanX_next, pacmanY_next;
    logic [1:0] direction_next;
    logic direction_changed_next;
    
    // set keyboard inputs and motion
    always_comb
    begin
        pacmanX_motion_next=pacmanX_motion;
        pacmanY_motion_next=pacmanY_motion;
        direction_next=direction;
        direction_changed_next=1'b0;
        
        if(freeze)
        begin
            pacmanX_next=pacmanX;
            pacmanY_next=pacmanY;
        end
        else
        begin
            // keyboard inputs
            if(keycode==8'd26)
            begin
                // W:up
                if(direction!=2'b00)
                begin
                    direction_changed_next=1'b1;
                    pacmanY_motion_next=-10'd1;
                    pacmanX_motion_next=10'd0;
                    direction_next=2'b00;
                end
            end
            if(keycode==8'd22)
            begin
                // S:down
                if(direction!=2'b01)
                begin
                    direction_changed_next=1'b1;
                    pacmanY_motion_next=10'd1;
                    pacmanX_motion_next=10'd0;
                    direction_next=2'b01;
                end    
            end
            if(keycode==8'd07)
            begin
                // D:right
                if(direction!=2'b11)
                begin
                    direction_changed_next=1'b1;
                    pacmanX_motion_next=10'd1;
                    pacmanY_motion_next=10'd0;
                    direction_next=2'b11;
                end
            end
            if(keycode==8'd04)
            begin
                // A:left
                if(direction!=2'b10)
                begin
                    direction_changed_next=1'b1;
                    pacmanX_motion_next=-10'd1;
                    pacmanY_motion_next=10'd0;
                    direction_next=2'b10;
                end
            end
            if(collision)
            begin
                pacmanX_next=pacmanX;
                pacmanY_next=pacmanY;
            end
            else
            begin
                pacmanX_next=pacmanX+pacmanX_motion_next;
                pacmanY_next=pacmanY+pacmanY_motion_next;
            end
        end
    end
    
    // position update logic
    always_ff @(posedge frame_clk)
    begin
        if(Reset)
        begin
            pacmanX_motion<=10'd0;
            pacmanY_motion<=10'd0;
            pacmanX<=pacmanX_start;
            pacmanY<=pacmanY_start;
            direction<=2'b00;
            direction_changed<=1'b0;
        end
        else
        begin
            if(!freeze)
            begin
                pacmanX_motion<=pacmanX_motion_next;
                pacmanY_motion<=pacmanY_motion_next;
                pacmanX<=pacmanX_next;
                pacmanY<=pacmanY_next;
                direction<=direction_next;
                direction_changed<=direction_changed_next;
            end
            else
            begin
                pacmanX<=pacmanX;
                pacmanY<=pacmanY;
                direction_changed<=1'b0;
            end
        end
    end

endmodule