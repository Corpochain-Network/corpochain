from __future__ import annotations

from typing import Generator, KeysView

SERVICES_FOR_GROUP = {
    "all": [
        "corpochain_harvester",
        "corpochain_timelord_launcher",
        "corpochain_timelord",
        "corpochain_farmer",
        "corpochain_full_node",
        "corpochain_wallet",
        "corpochain_data_layer",
        "corpochain_data_layer_http",
    ],
    # TODO: should this be `data_layer`?
    "data": ["corpochain_wallet", "corpochain_data_layer"],
    "data_layer_http": ["corpochain_data_layer_http"],
    "node": ["corpochain_full_node"],
    "harvester": ["corpochain_harvester"],
    "farmer": ["corpochain_harvester", "corpochain_farmer", "corpochain_full_node", "corpochain_wallet"],
    "farmer-no-wallet": ["corpochain_harvester", "corpochain_farmer", "corpochain_full_node"],
    "farmer-only": ["corpochain_farmer"],
    "timelord": ["corpochain_timelord_launcher", "corpochain_timelord", "corpochain_full_node"],
    "timelord-only": ["corpochain_timelord"],
    "timelord-launcher-only": ["corpochain_timelord_launcher"],
    "wallet": ["corpochain_wallet"],
    "introducer": ["corpochain_introducer"],
    "simulator": ["corpochain_full_node_simulator"],
    "crawler": ["corpochain_crawler"],
    "seeder": ["corpochain_crawler", "corpochain_seeder"],
    "seeder-only": ["corpochain_seeder"],
}


def all_groups() -> KeysView[str]:
    return SERVICES_FOR_GROUP.keys()


def services_for_groups(groups) -> Generator[str, None, None]:
    for group in groups:
        for service in SERVICES_FOR_GROUP[group]:
            yield service


def validate_service(service: str) -> bool:
    return any(service in _ for _ in SERVICES_FOR_GROUP.values())
