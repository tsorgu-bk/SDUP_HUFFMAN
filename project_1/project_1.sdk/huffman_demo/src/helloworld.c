/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */


#include <stdio.h>
#include <math.h>
#include <string.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "huff_coder4.h"
#include "huffman.h"


#define CODER_BASE_ADDR XPAR_HUFF_CODER4_0_S00_AXI_BASEADDR

#define INPUT_DATA HUFF_CODER4_S00_AXI_SLV_REG0_OFFSET
#define INPUT_SYMBOLS HUFF_CODER4_S00_AXI_SLV_REG1_OFFSET
#define OUTPUT_STATE HUFF_CODER4_S00_AXI_SLV_REG2_OFFSET
#define OUTPUT_DATA HUFF_CODER4_S00_AXI_SLV_REG3_OFFSET

#define SET_SYMBOL(param) (((u32)(param) & 0xFF) <<  8)
#define SET_CHARACTER(param) (((u32)(param) & 0xFF) <<  16)
#define SET_MESSAGE(param) (((u32)(param) & 0xFF) <<  24)



#define SYMBOLS_COUNT 28

uint8_t characters[28] = {' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '\0'};
uint8_t frequency[28] = {200, 82, 15, 28, 43, 127, 22, 20, 61, 70, 2, 8, 40, 24, 67, 75, 19, 1, 60, 63, 91, 28, 10, 23, 1, 20, 1, 0};
uint8_t symbolLength[28] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
uint32_t symbols[28] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


char message[100];
uint8_t MESSAGE_LEN = 0;

u32 outData[100];

u8 readData(u8 *data){
	u8 index = 0;
	while(1){
		u8 character = inbyte();
		data[index] = character;
		index++;
		if(character == '\n'){
			data[index]= 0;
			break;
		}
	}
	return index-1;
}

const char *byte_to_binary_u32(u32 x) {
    static char b[40];
    memset(b, 0, 40);
//    b[32] = 0;

    u8 string_index = 0;
    int x_index = 31;
    while(1) {
    	if (x & (1 << x_index)) {
			b[string_index] = '1';
		} else {
			b[string_index] = '0';
		}




    	string_index++;
    	if ((x_index % 8) == 0) {
    		b[string_index] = ' ';
    		string_index++;
    	}


    	x_index--;
    	if (x_index < 0) {
    		break;
    	}
    }


//    for (int i = 31; i > 0; i--) {
//    	if (x & (1 << i)) {
//    		b[31 - i] = '1';
//    	} else {
//    		b[31 - i] = '0';
//    	}
//    }
    return b;
}

int main()
{
	u32 mes1 = 0;
	u32 mes2 = 0;
    init_platform();

    u8 data[100] = {0};
    print("HELLO, WELCOME TO HALFMAN-HALFCODER!!!\n\r");
	huffman_tree(characters, frequency,symbols, symbolLength,SYMBOLS_COUNT);

    while(1){
		memset(message, 0, sizeof(message)); // clear old data
    	 u8 length = readData(&data);
    	 if(length){

    		 for(u8 i = 0; i<length; i++){
    			 if(data[i] > 'a' && data[i] < 'z'){
    				 data[i] -= 32;
    			 }
    		 }

			
			memcpy(message, (u8*)data, length); // copy new data
			printf("RECIEVED LENGHT: %d , RECIEVED DATA: %s", length, data);

			MESSAGE_LEN = length;
			print_huff(characters, frequency, symbols, symbolLength, SYMBOLS_COUNT);

		    // reset input registers
			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_SYMBOLS, 0);
			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 0);

			// manual reset
		    HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, (1 << 3));
			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 0);

			// send tables length
			mes1 = 1; // dataClock = 1
			mes1 |= SET_SYMBOL(SYMBOLS_COUNT);
			mes2 = SYMBOLS_COUNT;
			mes1 |= SET_CHARACTER(SYMBOLS_COUNT);
			mes1 |= SET_MESSAGE(MESSAGE_LEN + 1);

			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_SYMBOLS, mes2);
			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, mes1);
			HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 0);

			// send all data
			int i = 0;
			while(1) {
				mes1 = 1; // dataClock = 1

				if (i < SYMBOLS_COUNT) {
					mes1 |= SET_SYMBOL(symbols[i]);
					mes2 = symbolLength[i];
					mes1 |= SET_CHARACTER(characters[i]);
				} else {
					mes1 |= (1 << 2); // dataloaded = 1
				}

				if (i < MESSAGE_LEN) {
					mes1 |= SET_MESSAGE(data[i]);
				} else {
					mes1 |= (1 << 1); // messageLoaded = 1
				}
				HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_SYMBOLS, mes2);
				HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, mes1);
				HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 0);

				if (i >= SYMBOLS_COUNT && i >= MESSAGE_LEN) {
					break;
				}
				i++;
			}

			// wait for ready, and calculate time
			u32 result = 0;
			for(i=0; i < 100; i++ ) {
				result = HUFF_CODER4_mReadReg(CODER_BASE_ADDR, OUTPUT_STATE);
				if (result & 1) {
					break;
				}
			}

			printf("\n\nDONE, This is your coded data: \n\n");

			// get data from FPGA
			u32 limit = 10;
			for(u32 i  = 0; i < limit; i++) {
				HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 1); // data clock to 1
				HUFF_CODER4_mWriteReg(CODER_BASE_ADDR, INPUT_DATA, 0); // data clock to 0
				outData[i] = HUFF_CODER4_mReadReg(CODER_BASE_ADDR, OUTPUT_DATA);
				printf("DATA DEC: %lu, DATA BIN: %s,  Data index: %d\n", outData[i], byte_to_binary_u32(outData[i]), HUFF_CODER4_mReadReg(CODER_BASE_ADDR, OUTPUT_STATE) & 0xFFFF);

				if (i == 0) {
					//printf("out data 0 %d\n", outData[0]);

					u32 result = outData[0] >> 16;
					//printf("result %d\n", result);
					result += 16;
					if (result % 32) {
						limit = result / 32 + 1;
					} else {
						limit = result / 32;
					}
					//printf("LIMIT TO %d\n", limit);
				}
				outData[i] = 0;
			}
			printf("\n\nEND\n\n");
		}
    }

    cleanup_platform();
    return 0;
}
