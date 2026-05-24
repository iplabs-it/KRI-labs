# Lab: PIM

PIM multicast routing lab using Containerlab and FRR — 6 routers, 6 end hosts (multicast-capable), students configure PIM-SM on a pre-built OSPF network.

## Topology

6 routers (R1–R6) and 6 end hosts (PC1–PC6):

```
  PC1,PC2---R1---R2---R4---R5---PC3,PC4
              \      / \      /
               R3------R6
              /    \       \
                    R5      PC5,PC6
```

All routers run OSPF area 0. Students configure PIM Sparse Mode for multicast forwarding.

**Router-to-router links:**

| Link | Endpoints | Subnet |
|---|---|---|
| R1–R2 | eth1–eth1 | 192.168.12.0/24 |
| R1–R3 | eth2–eth1 | 192.168.13.0/24 |
| R2–R4 | eth2–eth1 | 192.168.24.0/24 |
| R3–R4 | eth2–eth2 | 192.168.34.0/24 |
| R3–R5 | eth3–eth1 | 192.168.35.0/24 |
| R3–R6 | eth4–eth2 | 192.168.36.0/24 |
| R4–R5 | eth4–eth2 | 192.168.45.0/24 |
| R4–R6 | eth3–eth1 | 192.168.46.0/24 |

**Host connections:**

| Host | Connected to | IP address | Gateway |
|---|---|---|---|
| PC1 | R1 (eth3) | 192.168.1.2/24 | 192.168.1.1 |
| PC2 | R1 (eth4) | 192.168.2.2/24 | 192.168.2.1 |
| PC3 | R5 (eth3) | 192.168.3.2/24 | 192.168.3.1 |
| PC4 | R5 (eth4) | 192.168.4.2/24 | 192.168.4.1 |
| PC5 | R6 (eth3) | 192.168.5.2/24 | 192.168.5.1 |
| PC6 | R6 (eth4) | 192.168.6.2/24 | 192.168.6.1 |

**Loopbacks:**

| Router | Loopback |
|---|---|
| R1 | 1.1.1.1/32 |
| R2 | 2.2.2.2/32 |
| R3 | 3.3.3.3/32 |
| R4 | 4.4.4.4/32 |
| R5 | 5.5.5.5/32 |
| R6 | 6.6.6.6/32 |

The initial configuration provides IP addressing and OSPF — students configure PIM on all routers.

## Files

| File | Description |
|---|---|
| `pim.clab.yml` | Containerlab topology definition |
| `daemons` | FRR daemon config (pimd enabled) |
| `R1.conf` – `R6.conf` | Router configs (IP addressing + OSPF) |

## Getting the Lab

**If you already have KRI-labs:**

```bash
cd ~/KRI-labs
git pull
git merge --no-edit origin/lab7-pim
```

**Starting on a new VM:**

```bash
cd ~
git clone https://github.com/iplabs-it/KRI-labs.git
cd KRI-labs
git merge --no-edit origin/lab7-pim
```

## Usage

```bash
cd ~/KRI-labs/pim
containerlab deploy --topo pim.clab.yml
docker exec -it clab-pim-R1 vtysh
```

When done:

```bash
containerlab destroy --topo pim.clab.yml
```
