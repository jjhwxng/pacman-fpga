module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    // USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    // UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    // HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,
    
    // HEX DISPLAYS
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);
    // clock and resets
    logic clk_25MHz, clk_125MHz;
    logic locked;
    logic reset_ah;
    assign reset_ah=reset_rtl_0;
    
    // keyboard and VGA signals
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic [9:0] drawX, drawY;
    logic hsync, vsync, vde;
    
    // pacman signals
    logic [9:0] pacmanX, pacmanY;
    logic [1:0] direction;
    logic collision;
    logic [3:0] collision_directions;
    logic direction_changed;
    logic [3:0] pacman_red, pacman_green, pacman_blue;
    logic pacman_sprite_on;
    
    // ghost signals
    // ghost 1 (pink)
    logic [9:0] ghostX, ghostY;
    logic [1:0] ghost_direction;
    logic ghost_collision_with_pacman;
    logic [3:0] ghost_red, ghost_green, ghost_blue;
    logic ghost_sprite_on;
    logic u, d, l, r;
    
    // ghost 1 (mint)
    logic [9:0] ghost2X, ghost2Y;
    logic [1:0] ghost2_direction;
    logic ghost2_collision_with_pacman;
    logic [3:0] ghost2_red, ghost2_green, ghost2_blue;
    logic ghost2_sprite_on;
    logic u2, d2, l2, r2;
    
    logic any_ghost_collision;
    assign any_ghost_collision=ghost_collision_with_pacman || ghost2_collision_with_pacman;
    
    // maze and pellet signals
    logic [3:0] maze_red, maze_green, maze_blue;
    logic [3:0] pellet_red, pellet_green, pellet_blue;
    logic maze_sprite_on, pellet_on;
    logic [3:0] maze_rom_data;
    
    // game state signals
    logic [9:0] score;
    logic game_over;
    logic pellet_eaten;
    logic [3:0] lives;
    logic life_lost;
    logic final_game_over;
    logic game_reset;
    
    // flash signals
    logic [23:0] flash_cnt;
    logic flash_toggle;
    logic [3:0] red, green, blue;
    
    // lives and reset logic
    logic ghost_collision_prev;
    assign game_reset=reset_ah || any_ghost_collision;
    
    always_ff @(posedge clk_25MHz)
    begin
        if(reset_ah)
        begin
            lives<=4'b1111;
            life_lost<=1'b0;
            ghost_collision_prev<=1'b0;
        end
        else
        begin
            ghost_collision_prev<=any_ghost_collision;
            if(any_ghost_collision && !ghost_collision_prev)
            begin
                if(lives!=4'b0000)
                begin
                    lives<=4'b0000;
                    case(lives)
                        4'b1111: lives<=4'b0111;
                        4'b0111: lives<=4'b0011;
                        4'b0011: lives<=4'b0001;
                        4'b0001: lives<=4'b0000;
                    endcase
                    life_lost<=1'b1;
                end
            end
            else
                life_lost<=1'b0;
        end
    end
    
    assign final_game_over=game_over || (lives==4'b0000);
    
    // hex display logic
    // score display (A)
    logic [3:0] hex_score [4];
    always_comb
    begin
        hex_score[0]=4'h0;
        hex_score[1]=score[9:8];
        hex_score[2]=score[7:4];
        hex_score[3]=score[3:0];
    end
    
    hex_driver hex_driver_score(
        .clk(Clk),
        .reset(reset_ah),
        .in(hex_score),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    // lives display (B)
    logic [3:0] hex_lives [4];
    always_comb
    begin
        hex_lives[0]=lives[3] ? 4'h1:4'h0;
        hex_lives[1]=lives[2] ? 4'h1:4'h0;
        hex_lives[2]=lives[1] ? 4'h1:4'h0;
        hex_lives[3]=lives[0] ? 4'h1:4'h0;
    end
    
    hex_driver hex_driver_lives(
        .clk(Clk),
        .reset(reset_ah),
        .in(hex_lives),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    // block instantiation
    mb_block mb_block_i(
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
    
    clk_wiz_0 clk_wiz(
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    vga_controller vga(
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );
    
    hdmi_tx_0 vga_to_hdmi(
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        .rst(reset_ah),
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        // unused
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        .TMDS_CLK_P(hdmi_tmds_clk_p),
        .TMDS_CLK_N(hdmi_tmds_clk_n),
        .TMDS_DATA_P(hdmi_tmds_data_p),
        .TMDS_DATA_N(hdmi_tmds_data_n)
    );
    
    // pacman logic
    pacman pacman_instance(
        .Reset(game_reset || life_lost),
        .frame_clk(vsync),
        .keycode(keycode0_gpio[7:0]),
        .collision(collision),
        .freeze(final_game_over),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .direction(direction),
        .direction_changed(direction_changed)
    );
    
    collision pacman_collision_detection(
        .vga_clk(clk_25MHz),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .direction(direction),
        .direction_changed(direction_changed),
        .collision(collision),
        .collision_directions(collision_directions)
    );
    
    pacman_example pacman_sprite(
        .vga_clk(clk_25MHz),
        .DrawX(drawX),
        .DrawY(drawY),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .direction(direction),
        .blank(vde),
        .pacman_sprite_on(pacman_sprite_on),
        .red(pacman_red),
        .green(pacman_green),
        .blue(pacman_blue)
    );
    
    // maze and pellets
    maze_example maze_sprite(
        .vga_clk(clk_25MHz),
        .DrawX(drawX),
        .DrawY(drawY),
        .blank(vde),
        .flash_mode(game_over),
        .flash_toggle(flash_toggle),
        .maze_data(maze_rom_data),
        .out_of_lives_mode(lives==4'b0000),
        .maze_on(maze_sprite_on),
        .red(maze_red),
        .green(maze_green),
        .blue(maze_blue)
    );
    
    pellet pellet_instance(
        .vga_clk(clk_25MHz),
        .reset(game_reset || life_lost),
        .DrawX(drawX),
        .DrawY(drawY),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .maze_on(maze_sprite_on),
        .maze_data(maze_rom_data),
        .pellet_on(pellet_on),
        .pellet_red(pellet_red),
        .pellet_green(pellet_green),
        .pellet_blue(pellet_blue),
        .pellet_eaten(pellet_eaten)
    );
    
    logic [9:0] romX=(drawX*320)/480;
    logic [9:0] romY=(drawY*256)/380;
    maze_rom maze_rom_pellet_inst(
        .clka(clk_25MHz),
        .addra(romY*320+romX),
        .douta(maze_rom_data)
    );
    
    // pink ghost logic
    collision_ghost ghostp_collision(
        .vga_clk(clk_25MHz),
        .reset(game_reset || life_lost),
        .ghostX(ghostX),
        .ghostY(ghostY),
        .collision_up(u),
        .collision_down(d),
        .collision_left(l),
        .collision_right(r)
    );
    
    ghostp ghostp_instance(
        .vga_clk(clk_25MHz),
        .reset(game_reset || life_lost),
        .frame_clk(vsync),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .collision_up(u),
        .collision_down(d),
        .collision_left(l),
        .collision_right(r),
        .ghostX(ghostX),
        .ghostY(ghostY),
        .ghost_direction(ghost_direction),
        .ghost_collision_with_pacman(ghost_collision_with_pacman),
        .freeze(final_game_over)
    );
    
    ghostp_example ghostp_sprite(
        .vga_clk(clk_25MHz),
        .DrawX(drawX),
        .DrawY(drawY),
        .ghostX(ghostX),
        .ghostY(ghostY),
        .blank(vde),
        .ghost_sprite_on(ghost_sprite_on),
        .red(ghost_red),
        .green(ghost_green),
        .blue(ghost_blue)
    );
    
    // mint ghost logic
    collision_ghost ghostm_collision(
        .vga_clk(clk_25MHz),
        .reset(game_reset || life_lost),
        .ghostX(ghost2X),
        .ghostY(ghost2Y),
        .collision_up(u2),
        .collision_down(d2),
        .collision_left(l2),
        .collision_right(r2)
    );
    
    ghostm ghostm_instance(
        .vga_clk(clk_25MHz),
        .reset(game_reset || life_lost),
        .frame_clk(vsync),
        .pacmanX(pacmanX),
        .pacmanY(pacmanY),
        .collision_up(u2),
        .collision_down(d2),
        .collision_left(l2),
        .collision_right(r2),
        .ghostX(ghost2X),
        .ghostY(ghost2Y),
        .ghost_direction(ghost2_direction),
        .ghost_collision_with_pacman(ghost2_collision_with_pacman),
        .freeze(final_game_over)
    );
    
    ghostm_example ghostm_sprite(
        .vga_clk(clk_25MHz),
        .DrawX(drawX),
        .DrawY(drawY),
        .ghostX(ghost2X),
        .ghostY(ghost2Y),
        .blank(vde),
        .ghost_sprite_on(ghost2_sprite_on),
        .red(ghost2_red),
        .green(ghost2_green),
        .blue(ghost2_blue)
    );
    
    // score logic
    parameter PELLETS=331;
    
    score score_instance(
        .clk(clk_25MHz),
        .reset(reset_ah || life_lost),
        .pellet_eaten(pellet_eaten),
        .pacman_dead(any_ghost_collision),
        .max_score(PELLETS),
        .score(score),
        .game_over(game_over)
    );
    
    // flash logic
    always_ff @(posedge clk_25MHz)
    begin
        if(reset_ah)
        begin
            flash_cnt<=24'd0;
            flash_toggle<=1'b0;
        end
        else
        begin
            if(lives==4'b0000)
            begin
                flash_cnt<=flash_cnt+1;
                if(flash_cnt==24'd4000000)
                begin
                    flash_toggle<=~flash_toggle;
                    flash_cnt<=24'd0;
                end
            end
            else if(game_over)
            begin
                flash_cnt<=flash_cnt+1;
                if(flash_cnt==24'd4000000)
                begin
                    flash_toggle<=~flash_toggle;
                    flash_cnt<=24'd0;
                end
            end
            else
            begin
                flash_toggle<=1'b0;
                flash_cnt<=24'd0;
            end
        end
    end
    
    // RGB output
    always_comb
    begin
        red=4'h0;
        green=4'h0;
        blue=4'h0;
        
        if(vde)
        begin
            if(pacman_sprite_on)
            begin
                red=pacman_red;
                green=pacman_green;
                blue=pacman_blue;
            end
            else if(ghost_sprite_on)
            begin
                red=ghost_red;
                green=ghost_green;
                blue=ghost_blue;
            end
            else if(ghost2_sprite_on)
            begin
                red=ghost2_red;
                green=ghost2_green;
                blue=ghost2_blue;
            end
            else if(pellet_on)
            begin
                red=pellet_red;
                green=pellet_green;
                blue=pellet_blue;
            end
            else
            begin
                red=maze_red;
                green=maze_green;
                blue=maze_blue;
            end
        end
    end
    

endmodule