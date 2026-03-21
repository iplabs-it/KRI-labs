# KRI Labs — Routing Protocol Exercises

Lab exercises for the KRI (Komutacja i Routing w Internecie) course, built with [Containerlab](https://containerlab.dev/) and [FRR (Free Range Routing)](https://frrouting.org/).

Each lab provides a pre-configured network topology that students deploy as lightweight Linux containers and then configure routing protocols interactively using `vtysh`.

## Available Labs

| # | Branch | Topic | Status |
|---|--------|-------|--------|
| 1 | `lab1-ospf` | OSPF | Not yet released |

Labs are released sequentially during the semester. When a lab becomes available, your instructor will let you know.

## Prerequisites

The labs are designed to run on a **Debian 12** virtual machine with Internet access, Docker, Containerlab, and FRR images.

## Quick Start

1. **Clone the repository** (first time only):

   ```bash
   cd ~
   git clone https://github.com/iplabs-it/KRI-labs.git
   cd KRI-labs
   ```

2. **Switch to the lab branch** when your instructor announces it:

   ```bash
   git pull
   git merge --no-edit origin/lab1-ospf
   ```

3. **Deploy the lab**:

   ```bash
   cd ospf
   containerlab deploy --topo ospf.clab.yml
   ```

4. **Connect to a router** and configure it:

   ```bash
   docker exec -it clab-ospf-R1 vtysh
   ```

5. **Capture traffic** (optional) — use the helper script from `common/`:

   ```bash
   bash ../common/capture.sh clab-ospf-R1 eth1
   ```

6. **Destroy the lab** when done:

   ```bash
   containerlab destroy --topo ospf.clab.yml
   ```

## Getting the Next Lab

When the next lab is released, just pull and merge:

```bash
cd ~/KRI-labs
git pull
git merge --no-edit origin/<labN-topic>
```

Each new lab adds its own directory — your previous work is not affected.

## Lab Checkpoints & Submission

Each lab has tasks that you should checkpoint as you complete them. The checkpoint system captures your router configurations, command history, and a VM fingerprint for integrity verification.

**Creating a checkpoint** — run from inside the lab directory (e.g., `ospf/`):

```bash
bash ../common/checkpoint.sh task1
```

This saves a timestamped snapshot of all FRR router configs to `~/Checkpoints/<lab_name>/`. You can create multiple checkpoints as you progress through tasks (e.g., `task1`, `task2`, `task3_complete`).

**Packaging for submission** — when you're done with all tasks:

```bash
bash ../common/package_submission.sh <lab_name>
```

For example: `bash ../common/package_submission.sh ospf`. This creates a `.tar.gz` archive in the current directory containing all your checkpoints. Submit this file according to your instructor's guidelines.

## Useful Commands

| Action | Command |
|---|---|
| Deploy a lab | `containerlab deploy --topo <file>.clab.yml` |
| Destroy a lab | `containerlab destroy --topo <file>.clab.yml` |
| List running containers | `containerlab inspect --topo <file>.clab.yml` |
| Enter router CLI | `docker exec -it clab-<lab>-<node> vtysh` |
| Enter container shell | `docker exec -it clab-<lab>-<node> bash` |
| Show routing table | Inside vtysh: `show ip route` |
| Live packet capture | `bash ../common/capture.sh clab-<lab>-<node> <iface>` |
| Save a checkpoint | `bash ../common/checkpoint.sh <task_name>` |
| Package submission | `bash ../common/package_submission.sh <lab_name>` |
