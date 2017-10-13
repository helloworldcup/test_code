#include "util/logging.h"
#include "leveldb/slice.h"
#include "test/mem.h"

#include <stddef.h>
#include <stdint.h>

int main(){
    size_t i = 1089;
    leveldb::Slice s = leveldb::NumberToString(i);
    uint64_t val;
    bool ok = leveldb::ConsumeDecimalNumber(&s, &val);
    leveldb::test::malloc_test();
    int v1=5;
    uint32_t v2 = 5; 
    int v3= -1;
    int v4 = -2;
    uint8_t k = 2;
    char d[20] = "abcdefghi";
    int v8[5]={1,2,3,4,5};
    leveldb::test::to_bites((leveldb::byte_pointer)&v1, sizeof(v1));
    leveldb::test::to_bites(d,sizeof(d)/sizeof(d[0]));
    leveldb::test::to_bites(v8, sizeof(v8)/sizeof(v8[0]));
}