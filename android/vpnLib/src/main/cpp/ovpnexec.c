#include <dlfcn.h>
#include <android/log.h>
#include <stdio.h>
#include <stdlib.h>

typedef int (*vpn_entry_t)(int, char **);

static vpn_entry_t resolve_symbol(void *handle) {
    vpn_entry_t entry = (vpn_entry_t)dlsym(handle, "openvpn_main");
    if (!entry) {
        entry = (vpn_entry_t)dlsym(handle, "main");
    }
    return entry;
}

int main(int argc, char **argv) {
    const char *const kLibName = "libopenvpn.so";
    void *handle = dlopen(kLibName, RTLD_NOW);
    if (handle == NULL) {
        const char *error = dlerror();
        __android_log_print(ANDROID_LOG_ERROR, "ovpnexec", "Failed to load %s: %s",
                            kLibName, error ? error : "unknown error");
        fprintf(stderr, "ovpnexec: cannot load %s: %s\n", kLibName, error ? error : "unknown");
        return EXIT_FAILURE;
    }

    vpn_entry_t entry = resolve_symbol(handle);
    if (entry == NULL) {
        const char *error = dlerror();
        __android_log_print(ANDROID_LOG_ERROR, "ovpnexec", "Entry point not found in %s: %s",
                            kLibName, error ? error : "unknown error");
        fprintf(stderr, "ovpnexec: entry point missing in %s: %s\n", kLibName,
                error ? error : "unknown");
        dlclose(handle);
        return EXIT_FAILURE;
    }

    int result = entry(argc, argv);
    dlclose(handle);
    return result;
}

