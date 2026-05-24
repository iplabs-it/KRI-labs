# Segment Routing lab (`sr`)

Hands-on lab for **Segment Routing over an MPLS data plane** with the **OSPF**
SR extensions and basic **SR Traffic Engineering**, built with
[ContainerLab](https://containerlab.dev) + [FRRouting](https://frrouting.org).
Follow the lab manual (`VMLAB_SR_FRR_clab_KRI.docx`) for the assignment itself;
this file is just a quick reference to the files and commands.

## Files in this folder

| File | Purpose |
|------|---------|
| `sr.clab.yml` | ContainerLab topology (5 routers, 2 hosts, links, MPLS sysctls) |
| `daemons` | FRR daemons enabled on every router (zebra, ospfd, bgpd, ldpd, **pathd**) |
| `R1.conf` … `R5.conf` | Initial FRR config for each router |

⚠ Review these files, but **do not modify** them — except where a task tells you
to (e.g. Task B2 has you add an SR policy to `R1.conf`).

## Topology

See **Figure 1** in the manual for the diagram. In short:

- Hosts: **H11** (`192.168.111.11`) on R1's LAN `192.168.111.0/24`;
  **H55** (`192.168.155.55`) on R5's LAN `192.168.155.0/24`.
- Core point-to-point links (`20.0.0.0/16`, /30 each):
  **R1–R2, R1–R3, R2–R3, R2–R4, R3–R4, R3–R5, R4–R5**.
- Routers **R1–R5** (FRR), hosts **H11**/**H55** (Linux). All in **OSPF area 0 / AS 100**;
  **iBGP** between R1 and R5 advertises the two host LANs.
- Loopbacks: `R1=1.1.1.1 … R5=5.5.5.5` (/32).
- **Prefix-SIDs / node labels** (SRGB 16000–23999): `R1=16100, R2=16200, R3=16300, R4=16400, R5=16500`.
- Interfaces inside a container: `eth0` = management; `eth1`, `eth2`, … = lab links.

## Running the lab

```bash
cd ~/KRI-labs/sr
containerlab deploy  -t sr.clab.yml     # start the lab
containerlab destroy -t sr.clab.yml     # tear it down
```

Access a router CLI (industry-standard, Cisco-like):
```bash
docker exec -it clab-sr-R1 vtysh        # e.g. R1; exit with: exit
```
Use a host (for ping / traceroute):
```bash
docker exec -it clab-sr-H11 bash
docker exec clab-sr-H11 ping 192.168.155.55
```

## Helper scripts (`~/KRI-labs/common/`)

```bash
bash ~/KRI-labs/common/capture.sh clab-sr-R1 eth1   # Wireshark capture on a link
bash ~/KRI-labs/common/checkpoint.sh <task_name>    # save configs after each task
bash ~/KRI-labs/common/package_submission.sh sr     # build the submission archive
```

## Troubleshooting

If, right after `deploy`, a router won't come up (no OSPF neighbours, `show zebra`
says it's not running, or H11→H55 ping fails), it's a known intermittent FRR
start-up glitch — fix it with:

```bash
bash ~/KRI-labs/common/sr-recover.sh
```

See `~/KRI-labs/common/sr-recover.README.md` for details.
