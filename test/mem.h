#ifndef _TEST_MOLLOC_H__
#define _TEST_MOLLOC_H__

#include<stdio.h>
#include <iostream>

namespace leveldb{
typedef unsigned char* byte_pointer;

namespace test{
    extern void malloc_test();
    extern void free_test(int* p);
    extern void free_test(void* p);
    extern void to_bites(byte_pointer start, int len);

    template<typename T>
    void to_bites(T* array, int len){
        if(len == 1){
            to_bites((byte_pointer)array, sizeof(array));
        }else{
            std::cout << "=====begin====" << std::endl;
            for(int i=0; i<len; i++){
                printf("[%d]==>", i);
                to_bites((byte_pointer)(array+i), sizeof(array[0]));
            }
            std::cout << "=====end=====" << std::endl;
        }
    }
}

}

#endif

