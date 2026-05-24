#!/bin/bash
# =============================================================================
# sr-recover.sh  --  recover the SR lab when a router's routing engine (zebra)
#                    failed to start cleanly after `containerlab deploy`.
#
# For the student lab VM, where the kernel already has MPLS support and the
# topology ships with enough memory. This script ONLY fixes the occasional
# FRR start-up crash on a node -- it does not touch the kernel or your configs.
#
# It is safe to run as many times as you like.
#
#   Usage:   bash ~/KRI-labs/common/sr-recover.sh
# =============================================================================
set -u
PREFIX=clab-sr
say(){ printf '\n\033[1m=== %s ===\033[0m\n' "$*"; }

# Sanity check: a missing kernel MPLS is NOT a zebra crash -- don't try to "fix" it.
if [ ! -e /proc/sys/net/mpls/platform_labels ]; then
  echo "ERROR: the kernel has no MPLS support (net.mpls is absent)."
  echo "       This is a VM setup problem, not a router crash -- contact your instructor."
  exit 1
fi

# Find the running FRR routers of the SR lab.
NODES=$(docker ps --format '{{.Names}}' | grep "^${PREFIX}-" | sort | while read -r n; do
          docker exec "$n" sh -c 'test -x /usr/lib/frr/zebra' 2>/dev/null && echo "$n"
        done)
if [ -z "$NODES" ]; then
  echo "No ${PREFIX}-* routers are running. Deploy the lab first:"
  echo "  cd ~/KRI-labs/sr && containerlab deploy -t sr.clab.yml"
  exit 1
fi

# Restart all FRR daemons on one node from a clean slate. Starting the routing
# daemons fresh lets them converge gradually, which avoids the start-up crash;
# the timeouts make sure a daemon that hangs can't block the script.
recover_node(){
  local n="$1" try
  docker exec "$n" sh -c 'wf=$(pgrep -f "watchfrr zebra"|head -1); kill -STOP $wf 2>/dev/null'   # pause supervisor
  for try in $(seq 1 15); do
    docker exec "$n" sh -c 'pkill -9 -f "/usr/lib/frr/(zebra|ospfd|bgpd|isisd|ldpd|staticd|pathd)" 2>/dev/null
                            rm -f /var/run/frr/*.pid /var/run/frr/*.vty 2>/dev/null'
    sleep 1
    timeout 8 docker exec "$n" sh -c '/usr/lib/frr/zebra -s 90000000 --daemon -A 127.0.0.1' 2>/dev/null
    sleep 2
    docker exec "$n" sh -c 'pgrep zebra >/dev/null' || continue            # zebra crashed at startup -> retry
    timeout 25 docker exec "$n" sh -c 'for d in ospfd bgpd isisd ldpd staticd pathd; do timeout 6 /usr/lib/frr/$d -F traditional --daemon -A 127.0.0.1 2>/dev/null; done' 2>/dev/null
    sleep 1
    timeout 25 docker exec "$n" vtysh -b >/dev/null 2>&1               # re-apply the node's own config
    sleep 6
    if docker exec "$n" sh -c 'pgrep zebra >/dev/null'; then
      docker exec "$n" sh -c 'wf=$(pgrep -f "watchfrr zebra"|head -1); kill -CONT $wf 2>/dev/null'
      return 0
    fi
  done
  docker exec "$n" sh -c 'wf=$(pgrep -f "watchfrr zebra"|head -1); kill -CONT $wf 2>/dev/null'
  return 1
}

say "Checking routers"
for n in $NODES; do
  if docker exec "$n" sh -c 'pgrep zebra >/dev/null' 2>/dev/null; then
    echo "  ${n#$PREFIX-}: OK"
  else
    printf "  %s: not started -- recovering ... " "${n#$PREFIX-}"
    recover_node "$n" && echo "fixed" || echo "FAILED (run this script again)"
  fi
done

say "End-to-end test (H11 -> H55)"
if docker ps --format '{{.Names}}' | grep -q "^${PREFIX}-H11$"; then
  if docker exec "${PREFIX}-H11" ping -c2 -W2 192.168.155.55 >/dev/null 2>&1; then
    echo "  OK -- the lab is working."
  else
    echo "  failed -- refreshing routing on all nodes ..."
    for n in $NODES; do docker exec "$n" vtysh -c 'clear ip ospf process' 2>/dev/null; done
    sleep 15
    docker exec "${PREFIX}-H11" ping -c2 -W2 192.168.155.55 >/dev/null 2>&1 \
      && echo "  OK after refresh -- the lab is working." \
      || echo "  still failing -- run this script once more."
  fi
else
  echo "  (host H11 not found; skipping)"
fi

say "Status"
for n in $NODES; do
  z=$(docker exec "$n" sh -c 'pgrep zebra >/dev/null && echo OK || echo DOWN' 2>/dev/null)
  f=$(docker exec "$n" vtysh -c 'show ip ospf neighbor' 2>/dev/null | grep -c Full)
  printf "  %-4s router=%-4s ospf_neighbors=%s\n" "${n#$PREFIX-}" "$z" "$f"
done
echo
echo "Still a node DOWN? Run this script again. Stuck after 2-3 runs?"
echo "  cd ~/KRI-labs/sr && containerlab destroy -t sr.clab.yml && containerlab deploy -t sr.clab.yml"
echo "  then run this script once more."
