`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 10:00:15
// Design Name: 
// Module Name: huff_coder
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



    module huff_coder(
    input  clock,  
    input  reset, 
    input  clockEnable,
    input  messageLoaded, 
    input  dataLoaded, 
    input  manualReset,
    input  [31:0] symbol, 
    input  [7:0] symbolLength, 
    input  [7:0] character, 
    input  [7:0] message,
    output reg [15:0] dataReady,
    output reg [31:0] dataOut,
    output reg [15:0] log
);


//State machine
reg [3:0] stateMachine;
parameter M_RESET = 4'h01, M_LOAD_DATA = 4'h02, M_PARSE_DATA = 4'h03, M_ADD_BITS_COUNT = 4'h04, M_DATA_PUSH = 4'h05, M_DATA_CLEAR = 4'h06;

reg [3:0] loadDataMachine;
reg [3:0] pushDataMachine;
parameter DETECT_EDGE = 4'h01, EDGE_DETECTED = 4'h02, HIGH_EDGE = 4'h03, INCREMENT_K = 4'h04;

reg [4:0] parseDataMachine;
parameter INCREMENT_J = 5'h01, GET_ACTUAL_CHARACTER = 5'h02, GET_CHARACTER_INDEX = 5'h03, GET_SYMBOL_LENGTH = 5'h04, CALCULATE_BIT_SHIFT = 5'h05,
CHECK_BIT_SHIFT = 5'h06, RECALCULATE_BIT_SHIFT = 5'h07, APPLY_NEW_BIT_SHIFT = 5'h08, CHECK_J = 5'h09, INCREMENT_BYTES_INDEX = 5'h0A;

reg [3:0] clearDataMachine;
parameter CLEAR_BYTE = 4'h01, INCREMENT_I = 4'h02;
//parameter P_DETECT_EDGE = 4'h01, P_EDGE_DETECTED = 4'h02, HIGH_EDGE = 4'h03, INCREMENT_K = 4'h04;

// iterators
reg [31:0] i = 32'h0;
reg [31:0] k = 32'h0;
reg [31:0] j = 32'h0;  

// detecting clock data change  
reg previousClockEnable;

parameter BUFFER_SIZE = 100;
// buffers for input data
reg [7:0] allMessage[0:BUFFER_SIZE-1];
reg [31:0] symbols[0:BUFFER_SIZE-1];
reg [7:0] symbolsLength[0:BUFFER_SIZE-1];
reg [7:0] characters[0:BUFFER_SIZE-1];

// buffer for putput data
reg [31:0] outputBits [0:BUFFER_SIZE-1];
integer allBitsCount;

// variables for proper working
reg [7:0] actualCharacterMessage;
reg [7:0] actualCharacterSymbolLength;
reg [31:0] actualCharacterSymbol;
reg [7:0] characterIndex;
reg [7:0] outBytesIndex;
reg [7:0] positive;
integer bitShift;


initial
begin
   stateMachine <= M_RESET;
end
    
always @(posedge clock) begin
    log <= stateMachine;
    if (manualReset) begin 
        stateMachine <= M_RESET;
    end
    if(reset || stateMachine == M_RESET) begin
        stateMachine <= M_LOAD_DATA;
        i <= 0;
        j <= 0;
        k <= 0;
        dataReady <= 0;
        dataOut <= 0;
        bitShift <= 16;
        outBytesIndex <= 0;
        allBitsCount <= 0;
        loadDataMachine <= DETECT_EDGE;
        parseDataMachine <= INCREMENT_J;
        pushDataMachine <= DETECT_EDGE;
        clearDataMachine <= CLEAR_BYTE;
        positive <= 0;
        actualCharacterSymbolLength <= 0;
        characterIndex <= 0;
        actualCharacterMessage <= 0;
        actualCharacterSymbol <= 0;
        previousClockEnable <= 0;
        outputBits[0] <= 0;
     end else begin
        case(stateMachine)
            M_LOAD_DATA: begin
                case(loadDataMachine)
                    DETECT_EDGE: begin
                        if (clockEnable != previousClockEnable) begin
                            previousClockEnable <= clockEnable;
                            loadDataMachine <= EDGE_DETECTED;
                        end else begin
                            loadDataMachine <= DETECT_EDGE;
                        end
                    end
                    
                    EDGE_DETECTED: begin
                        if (clockEnable) begin
                            loadDataMachine <= HIGH_EDGE;
                        end else begin
                            loadDataMachine <= DETECT_EDGE;
                        end
                    end 
                    
                    HIGH_EDGE: begin
                        if (!dataLoaded) begin
                            symbolsLength[k] <= symbolLength;
                            symbols[k] <= symbol;
                            characters[k] <= character;
                        end
                        
                        if (!messageLoaded) begin
                            allMessage[k] <= message;
                        end
                        
                        if(dataLoaded && messageLoaded) begin
                            stateMachine <= M_PARSE_DATA;
                            loadDataMachine <= DETECT_EDGE;
                            previousClockEnable <= 0;
                            k <= 0;
                        end else begin
                            loadDataMachine <= INCREMENT_K;
                        end
                    end
                    
                    INCREMENT_K: begin
                        k <= k + 1;
                        loadDataMachine <= DETECT_EDGE;
                    end
                endcase
            end
            
            M_PARSE_DATA: begin
                case(parseDataMachine)
                    INCREMENT_J: begin
                        j <= j + 1;
                        parseDataMachine <= CHECK_J;
                    end
                    
                    CHECK_J: begin
                        if (j < allMessage[0]) begin 
                            parseDataMachine <= GET_ACTUAL_CHARACTER;
                        end else begin
                            parseDataMachine <= INCREMENT_J;
                            j <= 0;
                            stateMachine <= M_ADD_BITS_COUNT;
                        end
                    end
                    
                    GET_ACTUAL_CHARACTER: begin
                        actualCharacterMessage <= allMessage[j];
                        parseDataMachine <= GET_CHARACTER_INDEX;
                    end
                    
                    GET_CHARACTER_INDEX: begin
                        if (actualCharacterMessage == 32) begin // spacja
                            characterIndex <= 1;
                        end else begin
                            characterIndex <= actualCharacterMessage - 63;
                        end
                        parseDataMachine <= GET_SYMBOL_LENGTH;
                    end
                    
                    GET_SYMBOL_LENGTH: begin
                        actualCharacterSymbolLength <= symbolsLength[characterIndex];
                        parseDataMachine <= CALCULATE_BIT_SHIFT;
                    end
                    
                    CALCULATE_BIT_SHIFT: begin
                        bitShift <= bitShift - actualCharacterSymbolLength;
                        allBitsCount <= allBitsCount + actualCharacterSymbolLength;
                        parseDataMachine <= CHECK_BIT_SHIFT;
                    end
                    
                    CHECK_BIT_SHIFT: begin
                        if (bitShift < 0) begin
                            outputBits[outBytesIndex + 1] <= 0;
                            positive <= -bitShift;
                            parseDataMachine <= RECALCULATE_BIT_SHIFT;
                        end else begin
                            outputBits[outBytesIndex] <= outputBits[outBytesIndex] | (symbols[characterIndex] << bitShift);
                            parseDataMachine <= INCREMENT_J;
                        end
                    end
                  
                    RECALCULATE_BIT_SHIFT: begin
                        outputBits[outBytesIndex] <= outputBits[outBytesIndex] | ( symbols[characterIndex] >> positive);
                        bitShift <= 32 - positive;
                        parseDataMachine <= INCREMENT_BYTES_INDEX;
                    end
                    
                    INCREMENT_BYTES_INDEX: begin
                        outBytesIndex <= outBytesIndex + 1;
                        parseDataMachine <= APPLY_NEW_BIT_SHIFT;
                    end
                    
                    APPLY_NEW_BIT_SHIFT: begin
                        outputBits[outBytesIndex] <= outputBits[outBytesIndex] | (symbols[characterIndex] << bitShift);
                        parseDataMachine <= INCREMENT_J;
                    end
                
                endcase
            end
            
            M_ADD_BITS_COUNT: begin
                outputBits[0] <= outputBits[0] | (allBitsCount << 16);
                dataReady <= 1;
                stateMachine <= M_DATA_PUSH;
            end
            
            M_DATA_PUSH: begin
                case(pushDataMachine)
                    DETECT_EDGE: begin
                        if (clockEnable != previousClockEnable) begin
                            previousClockEnable <= clockEnable;
                            pushDataMachine <= EDGE_DETECTED;
                        end else begin
                            pushDataMachine <= DETECT_EDGE;
                        end
                    end
                    
                    EDGE_DETECTED: begin
                        if (clockEnable) begin
                            pushDataMachine <= HIGH_EDGE;
                        end else begin
                            pushDataMachine <= DETECT_EDGE;
                        end
                    end 
                    
                    HIGH_EDGE: begin
                        if(k > outBytesIndex) begin
                            stateMachine <= M_DATA_CLEAR;
                            k <= 0;
                            dataOut <= 0;
                            pushDataMachine <= DETECT_EDGE;
                        end else begin
                            dataOut <= outputBits[k];
                            dataReady <= k;
                            pushDataMachine <= INCREMENT_K;
                        end
                    end
                    
                    INCREMENT_K: begin
                        k <= k + 1;
                        pushDataMachine <= DETECT_EDGE;
                    end
                endcase               
            end  
            
            M_DATA_CLEAR: begin
                case(clearDataMachine) 
                    CLEAR_BYTE: begin
                        if (i < BUFFER_SIZE) begin
                            allMessage[i] <= 0;
                            symbols[i] <= 0;
                            symbolsLength[i] <= 0;
                            characters[i] <= 0;
                            outputBits[i] <= 0;
                            clearDataMachine <= INCREMENT_I;
                        end else begin
                            clearDataMachine <= CLEAR_BYTE;
                            i <= 0;
                            stateMachine <= M_RESET;
                        end
                    end
                    
                    INCREMENT_I: begin
                        i <= i + 1;
                        clearDataMachine <= CLEAR_BYTE;
                    end
                endcase
            end   
        endcase
     end
 end
endmodule

