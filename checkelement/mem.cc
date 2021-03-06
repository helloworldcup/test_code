#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <cstdlib>
#include "mem.h"

namespace leveldb{

void Test::malloc_test(){
    int *p;
    p = (int*)malloc(sizeof(int)*64);
    int *k;
    k = (int*)malloc(sizeof(int)*128);
    char* z;
    z = (char*)malloc(sizeof(char)*96);

    free_test(p);
    free_test(z);
    free_test(k);
}

void Test::free_test(int *p){
    free(p);
}

void Test::free_test(void *p){
    free(p);
}

void Test::to_bites(byte_pointer start, int len){
    for (int i = len-1; i >= 0 ;i--)
    {
        for (int j = 7; j >= 0; j--)
            printf("%d", (start[i] >> j) & 0x1);
        printf(" ");
    }
    printf("\n");
}

}//end of leveldb