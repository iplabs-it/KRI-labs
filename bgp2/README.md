# Lab: BGP (part 2)

Advanced BGP lab using Containerlab and FRR — multi-AS topology with iBGP, eBGP, and OSPF as the IGP.

## Topology

5 ISP routers (R1–R5), 4 customer edge routers (CE11, CE21, CE22, CE33), and 4 end hosts (H11, H21, H22, H33):

```
                AS 11               AS 100              AS 200                    AS 21
  H11---CE11-----------R1----------R4----------R2-----------CE21---H21
                                    |          |
                                    R5---R3----+------CE22---H22
                                                \      AS 22
                                                 \
                                                  CE33---H33
                                                  AS 33
```

**Autonomous Systems:**

- AS 100: R1 (standalone, eBGP to CE11 and AS 200)
- AS 200: R2, R3, R4, R5 (iBGP full mesh, OSPF as IGP)
- AS 11: CE11 (customer, connected to R1)
- AS 21: CE21 (customer, connected to R2)
- AS 22: CE22 (customer, connected to R2)
- AS 33: CE33 (customer, connected to R3)

**Key subnets:**

- Customer networks: `172.1.0.0/24` (H11), `172.4.0.0/24` (H21), `172.4.1.0/24` (H22), `172.4.2.0/24` (H33)
- ISP backbone (OSPF): `20.0.x.0/30` point-to-point links
- ISP-to-customer (eBGP): `10.0.x.0/30` point-to-point links

Router configurations include iBGP/eBGP peering and OSPF — students work on advanced BGP features on top.

## Files

| File | Description |
|---|---|
| `bgp2.clab.yml` | Containerlab topology definition |
| `daemons` | FRR daemon config |
| `R1.conf` – `R5.conf` | ISP router configs with BGP and OSPF |
| `CE11.conf`, `CE21.conf`, `CE22.conf`, `CE33.conf` | Customer edge router configs |

## Getting the Lab

Check whether a copy of the repository already exists on the VM:

```bash
ls -d ~/KRI-labs/.git
```

**Case A, the path is printed (repository already there):**

```bash
cd ~/KRI-labs
git fetch
git merge --no-edit origin/lab4-bgp2
```

**Case B, "No such file or directory" (no repository yet):**

```bash
cd ~
git clone https://github.com/iplabs-it/KRI-labs.git
cd KRI-labs
git merge --no-edit origin/lab4-bgp2
```

## Usage

```bash
cd ~/KRI-labs/bgp2
containerlab deploy
docker exec -it clab-bgp2-R1 vtysh
```

Checkpoint after each task and package at the end:

```bash
bash ~/KRI-labs/common/checkpoint.sh task1
bash ~/KRI-labs/common/package_submission.sh bgp2
```

When done:

```bash
containerlab destroy
```
