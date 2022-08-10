#include <stdint.h> // uint8_t

#include "ufbx.h"

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    ufbx_scene *scene = ufbx_load_memory(data, size, NULL, NULL);
    ufbx_free_scene(scene);
    return 0;
}
