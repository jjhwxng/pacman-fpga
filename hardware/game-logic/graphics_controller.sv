module  graphics_controller 
( 
    input  logic        reset,
    input  logic        clk,
    input  logic [9:0]  pacmanX, pacmanY,
    input  logic        mouth_state,
    input  logic [9:0]  drawX, drawY,
    output logic [3:0]  color_index,
    output logic [9:0]  write_addrX,
    output logic [9:0]  write_addrY,
    output logic        write_en,
    output logic        render_done
);

parameter BLACK=4'b0000;
parameter BLUE=4'b0001;
parameter WHITE=4'b1111;
parameter YELLOW=4'b1110;

// drawing state machine
enum logic [3:0]
{
    idle,
    clear_screen,
    draw_maze,
    draw_pacman,
    done
} state, state_next;

logic [9:0] renderX, renderY;
logic [9:0] renderX_next, renderY_next;

logic [5:0] mazeX, mazeY;
logic [9:0] distX, distY;
logic wall, pellet, pacman;

// state initialization
always_ff @(posedge clk)
begin
    if(reset)
        state<=idle;
    else
        state<=state_next;
        renderX<=renderX_next;
        renderY<=renderY_next;
end

// state output logic
always_comb
begin
    color_index=BLACK;
    write_addrX=renderX;
    write_addrY=renderY;
    write_en=1'b0;
    render_done=1'b0;
//    renderX_next=renderX;
//    renderY_next=renderY;
    
    mazeX=renderX/16;
    mazeY=renderY/16;
    if(renderX>pacmanX)
        distX=renderX-pacmanX;
    else
        distX=pacmanX-renderX;
    if(renderY>pacmanY)
        distY=renderY-pacmanY;
    else
        distY=pacmanY-renderY;
        
    pacman=((distX*distX + distY*distY)<=(8*8));
    wall=(mazeX==0 | mazeX==3 | mazeY==0 | mazeY==29);
    pellet=((renderX%16==8) && (renderY%16==8) && !wall);
    case(state)
        idle:
        begin
            render_done=1'b1;
//            renderX_next=0;
//            renderY_next=0;
        end
        
        clear_screen:
        begin
            color_index=BLACK;
            write_en=1'b1;
        end
        
        draw_maze:
        begin
            write_addrX=renderX;
            write_addrY=renderY;
            write_en=1'b1;
            if(wall)
                color_index=BLUE;
            else if(pellet)
                color_index=WHITE;
            else
                color_index=BLACK;
        end
        
        draw_pacman:
        begin
            write_addrX=renderX;
            write_addrY=renderY;
            if(pacman)
            begin
                color_index=YELLOW;
                write_en=1'b1;
            end
            else
                write_en=1'b0;
        end
        
        done:
            render_done=1'b1;
    endcase
end

// next state logic
always_comb
begin
    state_next=state;
    renderX_next=renderX;
    renderY_next=renderY;
    
    case(state)
        idle:
        begin
            if(drawX==0 && drawY==0)
                state_next=clear_screen;
        end
        
        clear_screen:
        begin
            if(renderX==639)
            begin
                renderX_next=0;
                if(renderY==479)
                begin
                    renderY_next=0;
                    state_next=draw_maze;
                end
                else
                    renderY_next=renderY+1;
            end
            else
                renderX_next=renderX+1;
        end
        
        draw_maze:
        begin
            if(renderX==639)
            begin
                renderX_next=0;
                if(renderY==479)
                begin
                    renderY_next=0;
                    state_next=draw_pacman;
                end
                else
                    renderY_next=renderY+1;
            end
            else
                renderX_next=renderX+1;
        end
        
        draw_pacman:
        begin
            if(renderX==639)
            begin
                renderX_next=0;
                if(renderY==479)
                begin
                    renderY_next=0;
                    state_next=done;
                end
                else
                    renderY_next=renderY+1;
            end
            else
                renderX_next=renderX+1;
        end
        
        done:
        begin
            if(drawX==0 && drawY==0)
                state_next=idle;
        end
    endcase
end
endmodule
