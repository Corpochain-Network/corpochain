from __future__ import annotations

import os
from pathlib import Path

DEFAULT_ROOT_PATH = Path(os.path.expanduser(os.getenv("CORPOCHAIN_ROOT", "~/.corpochain/mainnet"))).resolve()

DEFAULT_KEYS_ROOT_PATH = Path(os.path.expanduser(os.getenv("CORPOCHAIN_KEYS_ROOT", "~/.corpochain_keys"))).resolve()

SIMULATOR_ROOT_PATH = Path(os.path.expanduser(os.getenv("CORPOCHAIN_SIMULATOR_ROOT", "~/.corpochain/simulator"))).resolve()
