#!/usr/bin/env bash

set -e

echo "Saving some usage notes..."
sudo bash -c "cat >/root/notes" << EOF

DNSmasq is setup to handle all *.consul dns requests by forwarding those requests to
the local Consul agent running on port 8600

Some commands that can be performed:

  nslookup nginx.service.dc1.consul
  nslookup haproxy.service.dc1.consul
  nslookup active.vault.service.dc1.consul
  nslookup standby.vault.service.dc1.consul


Vault has been setup to automatically unseal.
The root token and unseal keys are in /tmp/vault.init on the active node
(which in the demo situation is the first to become active)

Easiest way to find the active node is within Consul UI
click on node, see services and active/standby will be shown for vault

  grep Root /tmp/vault.init | awk '{print $4}'
  2ea0d25a-b958-57a2-e214-1e0633de5673

  grep Unseal /tmp/vault.init | awk '{print $4}'
  UtTwLkaWZHeYkuNsrqEmF+ZZzIaqBcof4Yy+EIng2OAB
  IYQL8+sptbdpoyPHUvgrI9hKJPtMg8RfF03Hifb300oC
  Ms8iEu7aM27PCGm3mm4bELtNoGMrlAiHTNwHLZ8k+QYD
  gqtQDrYPV2qQZ95dxH8DtWUed9rz4YYglwKfbfFff5gE
  keB577P80bM2zJQtDOkzhgYZ80KU9kr4zJNfyZiMVdQF


EOF
