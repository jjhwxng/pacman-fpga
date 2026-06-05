module ghost_color(
    input  logic wall_collision,
    output logic [3:0] ghost_red,
    output logic [3:0] ghost_green,
    output logic [3:0] ghost_blue
);
    
    // Normal ghost color: Red
    parameter [3:0] NORMAL_RED   = 4'hF;
    parameter [3:0] NORMAL_GREEN = 4'h0;
    parameter [3:0] NORMAL_BLUE  = 4'h0;
    
    // Collision color: White
    parameter [3:0] COLLISION_RED   = 4'hF;
    parameter [3:0] COLLISION_GREEN = 4'hF;
    parameter [3:0] COLLISION_BLUE  = 4'hF;
    
    always_comb begin
        if (wall_collision) begin
            ghost_red   = COLLISION_RED;
            ghost_green = COLLISION_GREEN;
            ghost_blue  = COLLISION_BLUE;
        end else begin
            ghost_red   = NORMAL_RED;
            ghost_green = NORMAL_GREEN;
            ghost_blue  = NORMAL_BLUE;
        end
    end
    
endmodule