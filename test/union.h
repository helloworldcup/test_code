#ifndef _TEST_UNION_H__
#define _TEST_UNION_H__

#include <stdint.h>

namespace leveldb{

union testunion{
    char mark;
    //float score;
    uint32_t value;
};

}

#endif