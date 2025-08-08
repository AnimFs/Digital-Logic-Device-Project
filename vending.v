module vending(clock_in, clk, y, sel_10, sel_15, sel_20, tin_05, tin_10, tin_20, out, cash_return, cash_reserve);

input clock_in; // input clock on FPGA
input sel_10, sel_15, sel_20;       // Porduct Price Selector
input tin_05, tin_10, tin_20;       // Input money




output reg clk; // output clock after dividing the input clock by divisor
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd100000000; // change value here
//parameter DIVISOR = 28'd2; // change value here

// The frequency of the output clk_out
always @(posedge clock_in)
begin
 counter <= counter + 28'd1;
 if(counter>=(DIVISOR-1))
	counter <= 28'd0;
 clk <= (counter<DIVISOR/2)?1'b1:1'b0;
end







output reg [2:0] y;
output out;
output [13:0]cash_reserve, cash_return;
wire [1:0] w; 
reg [2:0] Yn;

// PARAMETERS for states
parameter [2:0] zero_0 = 3'b000, 
                five_0 = 3'b001, 
                ten_0 = 3'b010, 
                fifteen_0 = 3'b011, 
                zero_1 = 3'b100, 
                five_1 = 3'b101, 
                ten_1 = 3'b110, 
                fifteen_1 = 3'b111;

// PARAMETERS for output 7 segment Displays
parameter [6:0] zero = 7'b0000001,
                one = 7'b1001111,
                two = 7'b0010010,
                three = 7'b0000110,
                four = 7'b1001100,
                five = 7'b0100100,
                six = 7'b0100000,
                seven = 7'b0001111,
                eight = 7'b0000000,
                nine = 7'b0000100;
        
// Encoding Input Amounts
assign w[1] = ~tin_10;
assign w[0] = ~tin_05;


always @(w,y, sel_10, sel_15, sel_20)
begin
    // For 20 Taka Product
    if(sel_20)
    begin
        case(y)
        zero_0: 
            if(w==2'b00)   Yn = zero_0;            // 0 taka input
            else if (w==2'b01) Yn = five_0;         // 5 taka niput
            else if (w==2'b10)  Yn = ten_0;       // 10 taka input
            else    Yn = zero_1;                  // 20 taka input

        five_0:
            if(w==2'b00)   Yn = five_0;            // 0 taka input
            else if (w==2'b01) Yn = ten_0;         // 5 taka niput
            else if (w==2'b10)  Yn = fifteen_0;       // 10 taka input
            else    Yn = five_1;                  // 20 taka input
    
        ten_0: 
            if(w==2'b00)   Yn = ten_0;            // 0 taka input
            else if (w==2'b01) Yn = fifteen_0;         // 5 taka niput
            else if (w==2'b10)  Yn = zero_1;       // 10 taka input
            else    Yn = ten_1;                  // 20 taka input

        fifteen_0:
            if(w==2'b00)   Yn = fifteen_0;            // 0 taka input
            else if (w==2'b01) Yn = zero_1;         // 5 taka niput
            else if (w==2'b10)  Yn = five_1;       // 10 taka input
            else    Yn = fifteen_1;                  // 20 taka input
        
        default: Yn = zero_0;

        endcase
    end

    // For 15 Taka Product
    else if (sel_15)
    begin
        case (y)
        zero_0: 
            if(w==2'b00)   Yn = zero_0;            // 0 taka input
            else if (w==2'b01) Yn = five_0;         // 5 taka niput
            else if (w==2'b10)  Yn = ten_0;       // 10 taka input
            else    Yn = five_1;                  // 20 taka input
        
        five_0:
            if(w==2'b00)   Yn = five_0;            // 0 taka input
            else if (w==2'b01) Yn = ten_0;         // 5 taka niput
            else if (w==2'b10)  Yn = zero_1;       // 10 taka input
            else    Yn = ten_1;                  // 20 taka input
        
        ten_0: 
            if(w==2'b00)   Yn = ten_0;            // 0 taka input
            else if (w==2'b01) Yn = zero_1;         // 5 taka niput
            else if (w==2'b10)  Yn = five_1;       // 10 taka input
            else    Yn = fifteen_1;                  // 20 taka input
        
        default: Yn = zero_0;

        endcase
    end

    // For 10 Taka Product
    else if (sel_10)
    begin
        case (y)
        zero_0: 
            if(w==2'b00)   Yn = zero_0;            // 0 taka input
            else if (w==2'b01) Yn = five_0;         // 5 taka niput
            else if (w==2'b10)  Yn = zero_1;       // 10 taka input
            else    Yn = ten_1;                  // 20 taka input
        
        five_0:
            if(w==2'b00)   Yn = five_0;            // 0 taka input
            else if (w==2'b01) Yn = zero_1;         // 5 taka niput
            else if (w==2'b10)  Yn = five_1;       // 10 taka input
            else    Yn = fifteen_1;                  // 20 taka input
        
        default: Yn = zero_0; 

        endcase
    end

    // If No Product Is Selected
    else
    Yn = zero_0;
    
end

// Sequential Block
always @(posedge clk) 
        y <= Yn;


// Output 
// Output 
assign out = ~ y[2];
// assign cash_return[13:7] = y[2]?  (y[1]? one:zero): zero;
// assign cash_return[6:0] = y[2]? (y[0]? five:zero): zero;

// assign cash_reserve[13:7] = (~ y[2])? (y[1]? one:zero): zero;
// assign cash_reserve[6:0] = (~ y[2])? (y[0]? five:zero): zero;


assign cash_reserve[13:7] = (y[1]? one:zero);
assign cash_reserve[6:0] = (y[0]? five:zero);



endmodule
