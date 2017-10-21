#include "util/logging.h"
#include "leveldb/slice.h"
#include "checkelement/mem.h"
#include "checkelement/union.h"

#include <stddef.h>
#include <stdint.h>

int main(){
    size_t i = 1089;
    leveldb::Slice s = leveldb::NumberToString(i);
    uint64_t val;
    bool ok = leveldb::ConsumeDecimalNumber(&s, &val);
    leveldb::Test::malloc_test();
    int v1=5;
    uint32_t v2 = 0x01020304; 
    int v3= -1;
    uint8_t k = 2;
    char d[20] = "abcdefghi";
    int v8[5]={1,2,3,4,5};
    leveldb::Test::to_bites((leveldb::byte_pointer)&v2, sizeof(v2));
    // leveldb::test::to_bites(d,sizeof(d)/sizeof(d[0]));
    // leveldb::test::to_bites(v8, sizeof(v8)/sizeof(v8[0]));
    leveldb::testunion testunion;
    testunion.value = 3;
    leveldb::Test::to_bites((leveldb::byte_pointer)&testunion, sizeof(testunion));
    testunion.mark = 'a';
    leveldb::Test::to_bites((leveldb::byte_pointer)&testunion, sizeof(testunion));
    testunion.score = 1.2;
    leveldb::Test::to_bites((leveldb::byte_pointer)&testunion, sizeof(testunion));
    testunion.numl = 2;
    leveldb::Test::to_bites((leveldb::byte_pointer)&testunion, sizeof(testunion));
}