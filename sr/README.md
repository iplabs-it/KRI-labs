# Segment Routing lab (`sr`), IS-IS edition

Lab 6 of the KRI course (`lab6-sr`). The previous OSPF-based edition is archived on the
branch `archive/lab6-sr-ospf`.

Same topology, addressing, link costs, prefix-SIDs and hosts as the OSPF lab, so
Figure 1 of the existing manual stays valid. The IGP is **IS-IS** (level-1, wide
metrics) because FRR implements **Flex-Algo only in isisd**, not in ospfd.

## Files

| File | Purpose |
|------|---------|
| `sr.clab.yml` | ContainerLab topology (5 routers, 2 hosts, MPLS sysctls); lab name `sr`, containers `clab-sr-*` |
| `daemons` | zebra, isisd, bgpd, pathd (no ospfd, no ldpd) |
| `R1.conf` … `R5.conf` | Initial configs: addressing, IS-IS + SR-MPLS, prefix-SIDs 16100…16500, iBGP R1–R5, link affinities |
| `sr-recover.sh`, `sr-recover.README.md` | Recovery script for the rare start-up glitch (see the manual appendix) |

## What is preconfigured

- IS-IS area `49.0001`, **level-1 only**, point-to-point links, hello 2 s / multiplier 5.
- SR-MPLS: SRGB 16000–23999, MSD 8, prefix-SID index `X00` on `X.X.X.X/32` (labels 16100…16500).
- `mpls-te on` with the router address, and `link-params` on every core link; the two R3 links
  on the shortest R1–R5 path (R1–R3 and R3–R5) carry the affinity **RED**
  (`affinity-map RED bit-position 0`). Nothing else uses them until the Flex-Algo task.
- iBGP between R1 and R5 advertising the two host LANs.

## Why level-1

FRR elects the Flex-Algo definition by scanning only the **level-1** LSP database
(`isisd/isis_flex_algo.c`, `_isis_flex_algo_elected`, same in 10.5 and master). In a
level-2-only area `show isis flex-algo` reports `Source: Not found` forever and no
algorithm SIDs are installed. Level-1 is the simplest fix for a single-area lab.

## Known FRR traps (same as the OSPF lab)

- A `name` under `policy color … endpoint …` makes pathd abort when the config is read from
  `frr.conf` (works live). Keep policies unnamed in config files.
- `traceroute` cannot show MPLS hops (no ICMP from inside the LSP); prove paths with captures:
  `sudo ip netns exec clab-sr-R2 tcpdump -nni eth3` or `common/capture.sh`.
- A policy steers nothing until the BGP route carries its colour (`set sr-te color N` in a
  route-map, or a colour extended community from the remote PE).

## Getting the lab

Check whether a copy of the repository already exists on the VM:

```bash
ls -d ~/KRI-labs/.git
```

**Case A, the path is printed (repository already there):**

```bash
cd ~/KRI-labs
git fetch
git merge --no-edit origin/lab6-sr
```

**Case B, "No such file or directory" (no repository yet):**

```bash
cd ~
git clone https://github.com/iplabs-it/KRI-labs.git
cd KRI-labs
git merge --no-edit origin/lab6-sr
```

## Running

```bash
cd ~/KRI-labs/sr
containerlab deploy
docker exec -it clab-sr-R1 vtysh
containerlab destroy
```

Checkpoint after each task and package at the end:

```bash
bash ~/KRI-labs/common/checkpoint.sh task1
bash ~/KRI-labs/common/package_submission.sh sr
```

If a router does not come up right after deploy, run `bash ~/KRI-labs/sr/sr-recover.sh`
(see `sr-recover.README.md`).

Useful: `show isis neighbor`, `show isis segment-routing node [algorithm 128]`,
`show isis flex-algo`, `show isis route algorithm 128`, `show mpls table`,
`show sr-te policy`, `show isis database detail <lsp-id>` (Router Capability TLV).
