# Lab: MPLS L3VPN

MPLS L3VPN lab using Containerlab and FRR — provider network with PE/P routers, VRFs, and customer edge connectivity.

## Topology

5 provider routers (R1–R5), 3 customer edge routers (CB1–CB3), and 3 end hosts (HB1–HB3):

```
                        Provider Network
         CB1---R1---R3---R4---R5---CB3
                         |
                         R2---CB2
  HB1---CB1              |
  HB2---CB2         (backbone)
  HB3---CB3
```

**Detailed connectivity:**

```
  HB1---CB1---R1---R3---R4---R5---CB3---HB3
                    |
                    R2---CB2---HB2
```

**Router roles:**

- R1, R2, R5: PE (Provider Edge) routers — connect to customer sites
- R3, R4: P (Provider/transit) routers — backbone only
- CB1, CB2, CB3: CE (Customer Edge) routers

**Key subnets:**

- Provider backbone (OSPF): `20.0.x.0/30` point-to-point links
- PE-to-CE links: `10.0.x.0/30` point-to-point links
- Customer networks: `172.16.1.0/24` (HB1), `172.16.2.0/24` (HB2), `172.16.3.0/24` (HB3)
- Loopbacks: `x.x.x.x/32` (R1=1.1.1.1, R2=2.2.2.2, ..., R5=5.5.5.5)

**Backbone links:**

| Link | Subnet |
|---|---|
| R1–R3 | `20.0.13.0/30` |
| R2–R3 | `20.0.23.0/30` |
| R3–R4 | `20.0.34.0/30` |
| R4–R5 | `20.0.45.0/30` |

**PE-to-CE links:**

| Link | Subnet |
|---|---|
| R1–CB1 | `10.0.11.0/30` |
| R2–CB2 | `10.0.21.0/30` |
| R5–CB3 | `10.0.51.0/30` |

The initial configuration provides OSPF on the backbone and basic IP addressing. Students configure MPLS, VRFs, and BGP VPNv4 to build the L3VPN service.

## Files

| File | Description |
|---|---|
| `l3vpn.clab.yml` | Containerlab topology definition |
| `daemons` | FRR daemon config (with MPLS enabled) |
| `R1.conf` – `R5.conf` | Provider router configs (OSPF backbone) |
| `CB1.conf`, `CB2.conf`, `CB3.conf` | Customer edge router configs |

## Getting the Lab

Check whether a copy of the repository already exists on the VM:

```bash
ls -d ~/KRI-labs/.git
```

**Case A, the path is printed (repository already there):**

```bash
cd ~/KRI-labs
git fetch
git merge --no-edit origin/lab5-l3vpn
```

**Case B, "No such file or directory" (no repository yet):**

```bash
cd ~
git clone https://github.com/iplabs-it/KRI-labs.git
cd KRI-labs
git merge --no-edit origin/lab5-l3vpn
```

## Usage

```bash
cd ~/KRI-labs/l3vpn
containerlab deploy
docker exec -it clab-l3vpn-R1 vtysh
```

Checkpoint after each task and package at the end:

```bash
bash ~/KRI-labs/common/checkpoint.sh task1
bash ~/KRI-labs/common/package_submission.sh l3vpn
```

When done:

```bash
containerlab destroy
```
