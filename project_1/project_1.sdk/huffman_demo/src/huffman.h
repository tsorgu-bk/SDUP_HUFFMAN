/*
 * huffman.h
 *
 *  Created on: 01.06.2021
 *      Author: klasa
 */

#ifndef SRC_HUFFMAN_H_
#define SRC_HUFFMAN_H_

#include <stdio.h>
#include <math.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;

u32 huffman_tree(u8 *charcters, u8 *frequency, u32 *symbols, u8 *symbolLength, u8 length);
void print_huff(u8 * characters, u8 *probability, u32 *symbols, u8 *symbolsLength_m, u8 length);

#endif /* SRC_HUFFMAN_H_ */
