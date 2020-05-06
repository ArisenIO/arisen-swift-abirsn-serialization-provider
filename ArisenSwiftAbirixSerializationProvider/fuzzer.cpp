// copyright defined in abirix/LICENSE.txt

#include "fuzzer.hpp"
#include <stdio.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"

extern "C" int LLVMFuzzerTestOneInput(const char* pos, size_t size) {
    auto* end = pos + size;

    fuzzer_header header;
    if (end - pos < sizeof(header))
        return 0;
    memcpy(&header, pos, sizeof(header));
    pos += sizeof(header);

    auto get_zero_terminated = [&](ptrdiff_t size) {
        if (end - pos < size)
            return (const char*)nullptr;
        auto* result = pos;
        pos += size;
        if (pos == result || pos[-1])
            return (const char*)nullptr;
        return result;
    };

    auto* abi = get_zero_terminated(header.abi_size);
    auto* type = get_zero_terminated(header.type_size);
    auto* data = get_zero_terminated(end - pos);
    if (!abi || !type || !data)
        return 0;

    auto context = abirix_create();
    bool ok;
    if (header.abi_is_bin)
        ok = abirix_set_abi_bin(context, header.contract, abi, header.abi_size);
    else
        ok = abirix_set_abi(context, header.contract, abi);

    if (ok) {
        if (header.operation == fuzzer_json_to_bin) {
            abirix_json_to_bin(context, header.contract, type, data);
            // printf("%s\n", abirix_get_bin_hex(context));
            abirix_json_to_bin_reorderable(context, header.contract, type, data);
            // printf("%s\n", abirix_get_bin_hex(context));
        } else {
            abirix_bin_to_json(context, header.contract, type, data, end - data);
        }
    }

    abirix_destroy(context);
    return 0;
}
#pragma clang diagnostic pop
