#ifndef INIT_SM6375_H
#define INIT_SM6375_H

#include <string>

enum device_variant {
    VARIANT_GTA9P_EU = 0,
    VARIANT_GTA9P_ASIA,
    VARIANT_GTA9P_TMO,
    VARIANT_GTA9P_UNLOCKED,
    VARIANT_MAX
};

typedef struct {
    std::string model;
    std::string codename;
} variant;

static const variant europe_models_gta9p = {
    .model    = "SM-X216B",
    .codename = "gta9p"
};

static const variant asia_models_gta9p = {
    .model    = "SM-X216B",
    .codename = "gta9p"
};

static const variant america_tmobile_models_gta9p = {
    .model    = "SM-X216B",
    .codename = "gta9p"
};

static const variant america_unlocked_models_gta9p = {
    .model    = "SM-X216B",
    .codename = "gta9p"
};

static const variant *all_variants[VARIANT_MAX] = {
    &europe_models_gta9p,
    &asia_models_gta9p,
    &america_tmobile_models_gta9p,
    &america_unlocked_models_gta9p
};

#endif // INIT_SM6375_H
