// copyright defined in abirix/LICENSE.txt

#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct abirix_context_s abirix_context;
typedef int abirix_bool;

// Create a context. The context holds all memory allocated by functions in this header. Returns null on failure.
abirix_context* abirix_create();

// Destroy a context.
void abirix_destroy(abirix_context* context);

// Get last error. Never returns null. The context owns the returned string.
const char* abirix_get_error(abirix_context* context);

// Get generated binary. The context owns the returned memory. Functions return null on error; use abirix_get_error to
// retrieve error.
int abirix_get_bin_size(abirix_context* context);
const char* abirix_get_bin_data(abirix_context* context);

// Convert generated binary to hex. The context owns the returned string. Returns null on error; use abirix_get_error to
// retrieve error.
const char* abirix_get_bin_hex(abirix_context* context);

// Name conversion. The context owns the returned memory. Functions return null on error; use abirix_get_error to
// retrieve error.
uint64_t abirix_string_to_name(abirix_context* context, const char* str);
const char* abirix_name_to_string(abirix_context* context, uint64_t name);

// Set abi (JSON format). Returns false on error.
abirix_bool abirix_set_abi(abirix_context* context, uint64_t contract, const char* abi);

// Set abi (binary format). Returns false on error.
abirix_bool abirix_set_abi_bin(abirix_context* context, uint64_t contract, const char* data, size_t size);

// Set abi (hex format). Returns false on error.
abirix_bool abirix_set_abi_hex(abirix_context* context, uint64_t contract, const char* hex);

// Get the type name for an action. The contract owns the returned memory. Returns null on error; use abirix_get_error
// to retrieve error.
const char* abirix_get_type_for_action(abirix_context* context, uint64_t contract, uint64_t action);

// Convert json to binary. Use abirix_get_bin_* to retrieve result. Returns false on error.
abirix_bool abirix_json_to_bin(abirix_context* context, uint64_t contract, const char* type, const char* json);

// Convert json to binary. Allow json field reordering. Use abirix_get_bin_* to retrieve result. Returns false on error.
abirix_bool abirix_json_to_bin_reorderable(abirix_context* context, uint64_t contract, const char* type,
                                           const char* json);

// Convert binary to json. The context owns the returned string. Returns null on error; use abirix_get_error to retrieve
// error.
const char* abirix_bin_to_json(abirix_context* context, uint64_t contract, const char* type, const char* data,
                               size_t size);

// Convert hex to json. The context owns the returned memory. Returns null on error; use abirix_get_error to retrieve
// error.
const char* abirix_hex_to_json(abirix_context* context, uint64_t contract, const char* type, const char* hex);

#ifdef __cplusplus
}
#endif
