module score(
    input logic clk,
    input logic reset,
    input logic pellet_eaten,
    input logic pacman_dead,
    input logic [9:0] max_score,
    output logic [9:0] score,
    output logic game_over
);

    always_ff @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            score<=0;
            game_over<=0;
        end
        else
        begin
            if(pacman_dead)
            begin
                score<=0;
                game_over<=0;
            end
            else if(!game_over && pellet_eaten)
            begin
                score<=score+1;
                if(score+1==max_score)
                    game_over<=1;
            end
        end
    end
endmodule