`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2021 20:20:24
// Design Name: 
// Module Name: huffman_coder_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module huffman_coder_tb();
    parameter SYMBOLS_COUNT = 28;
    
    reg clock;
    reg clockEnable;
    reg reset;
    reg messageLoaded;
    reg dataLoaded;
    reg manualReset;
    reg [31:0] symbol;
    reg [7:0] symbolLength;
    reg [7:0] character;
    reg [7:0] message;
    reg [15:0] dataReady;
    reg [31:0] dataOut;
    reg [15:0] log;
    
    parameter MESSAGE_LEN = 37;
    reg [7:0] allMessage[0:MESSAGE_LEN]           = {MESSAGE_LEN, 65, 76, 65, 32, 77, 65, 32, 75, 79, 84, 65, 0};   
    reg [31:0] symbols[0:SYMBOLS_COUNT]        = {SYMBOLS_COUNT, 0, 14, 48, 9, 31, 4, 4, 51, 6, 11, 44, 23, 30, 7, 10, 13, 49, 90, 5, 7, 0, 8, 10, 6, 183, 50, 182, 0};
    reg [7:0] symbolsLength[0:SYMBOLS_COUNT]    = {SYMBOLS_COUNT, 0, 4, 6, 5, 5, 3, 5, 6, 4, 4, 8, 7, 5, 5, 4, 4, 6, 9, 4, 4, 3, 5, 6, 5, 10, 6, 10, 0};
    
    reg [7:0] characters[0:SYMBOLS_COUNT]      = {SYMBOLS_COUNT, 32, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 0};    
    

    huffman_coder cod(clock, reset, clockEnable, messageLoaded, dataLoaded, manualReset, symbol, symbolLength, character, message, dataReady, dataOut, log);
    
    reg [31:0] readyBits [100];
    reg [31:0] allBitsCount;
    reg [31:0] allRegistersCount;
    
    //Clock generator
    initial
    begin
         clock <= 1'b1;
         messageLoaded <= 1'b0;
         dataLoaded <= 1'b0;
         clockEnable <= 1'b0;
         manualReset <= 1'b0;
    end
    
    always
     #5 clock <= ~clock;
    
    //Reset signal
    initial
    begin
         reset <= 1'b1;
        #10 reset <= 1'b0;
        symbol <= 1'b0;
    end 
    
    always@(posedge clock)
    begin
        integer i=0;
        #20
        while(1) begin  
            if (i > SYMBOLS_COUNT && i > MESSAGE_LEN ) begin
                break;
            end
          
            if (i < SYMBOLS_COUNT) begin
                dataLoaded <= 1'b0;
                symbol <= symbols[i];
                symbolLength <= symbolsLength[i];
                character <= characters[i];  
            end else begin
                dataLoaded <= 1'b1;
            end
            
            if (i < MESSAGE_LEN) begin
                messageLoaded <= 1'b0;
                message <= allMessage[i];
            end else begin
                messageLoaded <= 1'b1;
            end   
            
            #100 clockEnable = 1'b1;
            #100 clockEnable = 1'b0;
            
            i = i + 1;
        end
        
        while(!dataReady) begin
            i = 0;
            // wait for data ready
            #10;
        end
        
        for(int i =0; i < 50; i++) begin
            #100 clockEnable = 1'b1;
            #100 clockEnable = 1'b0;
            readyBits[i] = dataOut;
            if (i == 0) begin
                allBitsCount = dataOut >> 16;
                allBitsCount += 16;
                allRegistersCount = allBitsCount / 32;
                allRegistersCount++;
            end
            
            if (i ==  allRegistersCount) begin
                break;
            end
        end
        #5000
        
        $stop;
    end
endmodule


