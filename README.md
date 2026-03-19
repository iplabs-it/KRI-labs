# KRI Labs — Routing Protocol Exercises

Lab exercises for the KRI (Komutacja i Routing w Internecie) course, built with [Containerlab](https://containerlab.dev/) and [FRR (Free Range Routing)](https://frrouting.org/).

Each lab provides a pre-configured network topology that students deploy as lightweight Linux containers and then configure routing protocols interactively using `vtysh`.

## Available Labs

| # | Branch | Topic | Status |
|---|--------|-------|--------|
| 1 | `lab1-ospf` | OSPF | Not yet released |
| 2 | `lab2-isis` | IS-IS | Not yet released |

Labs are released sequentially during the semester. When a lab becomes available, your instructor will let you know.

## Prerequisites

The labs are designed to run on a **Debian 12** virtual machine with Internet access, Docker, Containerlab, and FRR images.

## Quick Start

1. **Clone the repository** (first time only):

   ```bash
   cd ~
   git clone https://github.com/iplabs-it/kri-labs.git
   cd kri-labs
   ```

2. **Switch to the lab branch** when your instructor announces it:

   ```bash
   git pull
   git merge origin/lab1-ospf
   ```

3. **Deploy the lab**:

   ```bash
   cd ospf
   sudo containerlab deploy --topo ospf.clab.yml
   ```

4. **Connect to a router** and configure it:

   ```bash
   sudo docker exec -it clab-ospf-R1 vtysh
   ```

5. **Capture traffic** (optional) — use the helper script from `common/`:

   ```bash
   bash ../common/capture.sh clab-ospf-R1 eth1
   ```

6. **Destroy the lab** when done:

   ```bash
   sudo containerlab destroy --topo ospf.clab.yml
   ```

## Getting the Next Lab

When the next lab is released, just pull and merge:

```bash
cd ~/kri-labs
git pull
git merge origin/lab2-isis
```

Each new lab adds its own directory — your previous work is not affected.

## Useful Commands

| Action | Command |
|---|---|
| Deploy a lab | `sudo containerlab deploy --topo <file>.clab.yml` |
| Destroy a lab | `sudo containerlab destroy --topo <file>.clab.yml` |
| List running containers | `sudo containerlab inspect --topo <file>.clab.yml` |
| Enter router CLI | `sudo docker exec -it clab-<lab>-<node> vtysh` |
| Enter container shell | `sudo docker exec -it clab-<lab>-<node> bash` |
| Show routing table | Inside vtysh: `show ip route` |
| Live packet capture | `bash ../common/capture.sh clab-<lab>-<node> <iface>` |
