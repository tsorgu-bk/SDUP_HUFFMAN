/*
 * huffman.c
 *
 *  Created on: 01.06.2021
 *      Author: klasa
 */

#include "huffman.h"

static uint32_t* symbols_code;
static uint8_t* symbol_length;

typedef struct Node {
	u8 character;
	u32 frequency;
	u32 code;
	u8 code_len;
	struct Node *left, *right;

}Node_t;


static Node_t node_tab_pointers[2 * 50];
static Node_t start_node;

int comp(const void *p, const void *q) {
  Node_t *n1 = (Node_t*)p;
  Node_t *n2 = (Node_t*)q;

  if (n1->frequency < n2->frequency) return 1;
  if (n1->frequency > n2->frequency) return -1;
  return 0;
}

u8 get_index(u8 c) {
    if (c == ' ') {
        return 0;
    } else {
        c -= 'A';
        c++;
        return c;
    }
}

u8 get_len(Node_t* tab) {
    uint8_t i;
    for (i = 0; i < 255; ++i) {
        if(tab[i].frequency == 0) {
            return i;
        }
    }
    return 0;
}

const char *byte_to_binary(double x, double len) {
	//print("BTB \n");
    static char b[9];
    b[0] = '\0';
    int z;
    z =(int) pow(2, len -1);
    for (; z > 0; z >>= 1u ) {
        strcat(b, (((int)x & z) == z) ? "1" : "0");
    }

    return b;
}

void code_right(Node_t* node);

void code_left(struct  Node* node) {
	//print("CODE LEFT \n");
    node->code_len++;
    node->code = node->code << 1u;
    if (node->character > 0) {
        u8 index = get_index(node->character);
        symbols_code[index] = node->code;
        symbol_length[index] = node->code_len;
    } else {
        node->left->code_len = node->code_len;
        node->left->code = node->code;
        code_left(node->left);

        node->right->code_len = node->code_len;
        node->right->code = node->code;

        code_right(node->right);
    }
}


void code_right(Node_t* node) {
	//print("CODE RIGHT \n");
    node->code_len++;
    node->code = node->code << 1u;
    node->code |= 1u;

    if (node->character > 0) {
        u8 index = get_index(node->character);
        symbols_code[index] = node->code;
        symbol_length[index] = node->code_len;
    } else {
        node->left->code_len = node->code_len;
        node->left->code = node->code;
        code_left(node->left);

        node->right->code_len = node->code_len;
        node->right->code = node->code;

        code_right(node->right);
    }
}

void code_it(Node_t* node){
	//print("CODE IT \n");
    node->left->code = 0;
    node->left->code_len = 0;
    code_left(node->left);

    node->right->code = 0;
    node->right->code_len = 0;
    code_right(node->right);

}


u32 huffman_tree(u8 *characters, u8 *frequency, u32 *symbols, u8 *symbolLength, u8 length){
	//print("HUFF TREE \n");
	Node_t node_tab[length];
    symbols_code = symbols;
    symbol_length = symbolLength;

	for(u8 i = 0; i<length;i++){
		node_tab[i].character = characters[i];
		node_tab[i].frequency = frequency[i];
	}

	u8 len = length;
	u16 index = 0;

	while(1){
		qsort(node_tab, length, sizeof(Node_t), comp);
		len = get_len(node_tab);
		if(len < 2){
			start_node = node_tab[0];
			break;
		}
		len -=2;

		node_tab_pointers[index]=node_tab[len];
		node_tab_pointers[index+1]=node_tab[len+1];
		node_tab[len].frequency =node_tab_pointers[index].frequency + node_tab_pointers[index+1].frequency;
		node_tab[len].right = &node_tab_pointers[index];
		node_tab[len].left = &node_tab_pointers[index+1];
		node_tab[len].character = 0;
		node_tab[len + 1].frequency = 0;
		node_tab[len + 1].character = 0;
		index +=2;

	}
	   code_it(& start_node);
}

void print_huff(uint8_t* characters, uint8_t* freq, uint32_t* symbols, uint8_t* symbolsLength_m, uint8_t length) {
	print("HUFFMAN CODES: \n");
	u8 databuffer[100]= {0};
	u8 tl=0;
    for(uint8_t i = 0; i < length; i++) {
       tl = sprintf(databuffer, "Character:	%c,	Probability [0.XXX]:	%d,	Bits used: %d,	Code: %s \n", characters[i], freq[i], symbolsLength_m[i], byte_to_binary(symbols[i], symbolsLength_m[i]));
       print(databuffer);
    }

}

