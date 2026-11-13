#!/usr/bin/env python3
"""Execute the production CallKit state machine with deterministic framework/SDK doubles.

Requires macOS and Swift. These tests exercise race handling, not PushKit delivery,
Apple framework integration, or compatibility with the binary linphone-sdk pod.
"""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'Linhome/linphonecore/NativeIncomingCallManager.swift').read_text()
source = '\n'.join(line for line in source.splitlines() if not line.startswith('import '))
# Exercise the actual launch preference and account transition methods as well.
prefs = (root / 'Linhome/linphonecore/CorePreferences.swift').read_text()
prefs = 'class CorePreferences {' + prefs.split('class CorePreferences {', 1)[1].split('\tvar config:Config', 1)[0] + '}\n'
account = (root / 'Linhome/linphonecore/Account+Extension.swift').read_text().split('extension Account {', 1)[1]
source += '\n' + prefs + '\nextension Account {' + account + '\n'
with tempfile.TemporaryDirectory(prefix='linhome-native-calls-') as tmp:
    main = Path(tmp) / 'main.swift'
    main.write_text((root / 'tests/native-incoming-call-stubs.swift').read_text()
                    + '\n' + source + '\n'
                    + (root / 'tests/native-incoming-call-scenarios.swift').read_text())
    binary = Path(tmp) / 'tests'
    subprocess.run(['xcrun', 'swiftc', '-module-cache-path', str(Path(tmp) / 'cache'), str(main), '-o', str(binary)], check=True)
    subprocess.run([str(binary)], check=True)
