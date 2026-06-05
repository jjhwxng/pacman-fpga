module  frame_buffer 
( 
    input  logic        reset,
    input  logic        clk,
    input  logic [9:0]  write_addrX,
    input  logic [9:0]  write_addrY,
    input  logic [3:0]  color_index,
    input  logic        write_en,
    input  logic [9:0]  read_addrX,
    input  logic [9:0]  read_addrY,
    output logic [3:0]  pixel_color
);

parameter WIDTH=640;
parameter HEIGHT=480;

logic [3:0] framebuffer [0:WIDTH-1][0:HEIGHT-1];

// write to frame buffer
always_ff @(posedge clk)
begin
    if(reset)
    begin
        for(int x=0; x<WIDTH; x++)
        begin
            for(int y=0; y<HEIGHT; y++)
            begin
                framebuffer[x][y]<=4'b0000;
            end
        end
    end
    else if(write_en && write_addrX<WIDTH && write_addrY<HEIGHT)
        framebuffer[write_addrX][write_addrY]<=color_index;
end

// read from frame buffer
always_ff @(posedge clk)
begin
    if(read_addrX<WIDTH && read_addrY<HEIGHT)
    begin
        pixel_color<=framebuffer[read_addrX][read_addrY];
    end
    else 
        pixel_color<=4'b0000;
end
endmodule
