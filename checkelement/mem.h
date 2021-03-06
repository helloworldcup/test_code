#ifndef _TEST_MOLLOC_H__
#define _TEST_MOLLOC_H__

#include<stdio.h>
#include <iostream>

namespace leveldb{
typedef unsigned char* byte_pointer;

class Test{
public:
    static void malloc_test();
    static void free_test(int* p);
    static void free_test(void* p);
    static void to_bites(byte_pointer start, int len);

    template<typename T>
    static void to_bites(T* array, int len){
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
};

}

#endif

