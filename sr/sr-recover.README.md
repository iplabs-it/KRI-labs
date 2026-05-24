# Recovering the SR lab if a router doesn't start

The lab's virtual routers (R1–R5) run FRRouting. Occasionally, the first time the
lab boots, one router's routing engine (`zebra`) fails to start cleanly. This is a
known, harmless FRR start-up glitch — **not** a mistake in your configuration. When
it happens that router sits "dead": OSPF won't form on it and end-to-end traffic
(H11 ↔ H55) breaks.

## When to run it

Run the recovery script if, shortly after `containerlab deploy`, you see any of these:

- `ping` from **H11 to H55 fails**, or `traceroute` dies after the first hop.
- On some router, `show ip ospf neighbor` reports `OSPF is not enabled` or shows
  fewer neighbours than expected
  (expected: **R1=2, R2=3, R3=4, R4=3, R5=2**).
- `show running-config` on a router is almost empty (just the hostname).
- `show zebra` on a router says *zebra is not running*.

Quick way to check a router (replace `R3` with the one that looks wrong):

```
docker exec clab-sr-R3 vtysh -c "show ip ospf neighbor"
```

## How to run it

From a terminal on the lab VM:

```
bash ~/KRI-labs/common/sr-recover.sh
```

It checks every router, restarts only the ones that didn't start, runs an H11→H55
connectivity test, and prints a status table. It does not change your configs and
is safe to run as many times as you like.

## If it's still broken

- **Run it again** — the last router to recover sometimes needs a second pass.
- Still stuck after 2–3 runs? Reset the lab and recover once more:
  ```
  cd ~/KRI-labs/sr
  containerlab destroy -t sr.clab.yml
  containerlab deploy  -t sr.clab.yml
  bash ~/KRI-labs/common/sr-recover.sh
  ```
- If you instead see a message about **“MPLS support disabled”**, that is a VM
  problem, not a router crash — this script won't fix it; tell your instructor.
