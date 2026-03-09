# Qt Transfer App

Send messages and files between two machines over TCP or UDP.

---

## Quick Start (No Docker)

This is the easiest way on both Windows and Linux.

**1. Build**

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel
```

**2. Run a server in one terminal**

```bash
./app --server --port 5000
.\app.exe --server --port 5000
```

**3. Run the client in another terminal**

```bash
./app      # Linux
.\app.exe  # Windows
```

In the UI: pick TCP or UDP -> enter the server's IP -> click **Connect** -> send messages or files.

---

## Docker

### Can the GUI client run inside Docker on Windows?

**Short answer: not with docker compose alone.**

Docker Desktop on Windows runs containers inside a hidden Linux VM. That VM has no screen, so a Qt window has nowhere to appear. On Linux this is solved by sharing the host's X11 socket into the container — Windows has no built-in X11 server so the same trick doesn't work out of the box.

**Practical recommendation for Windows:**

> Run the **server** in Docker, run the **client** as a native `.exe` on the same machine.

---

### Linux — server + client both in Docker

Linux hosts have X11, so both modes work.

```bash
# Allow Docker containers to use your display
xhost +local:docker

docker compose up
```

The `server` service starts automatically headless. The `client` service opens a GUI window on your desktop. Connect to `127.0.0.1:5000`.

To stop:

```bash
docker compose down
```

---

### Windows — server in Docker, client as native .exe

**Step 1 — build and start the server container**

```powershell
docker compose up
```

The server listens on port 5000 (TCP and UDP) on your machine.

**Step 2 — run the native client**

Import CMakeLists.txt to QtCreator and just run the project.

In the UI: enter `127.0.0.1` as the host, port `5000`, click **Connect**.

### Environment variables

| Variable   | Default | Effect                         |
| ---------- | ------- | ------------------------------ |
| `SERVER=1` | off     | Run as headless server         |
| `PORT`     | `5000`  | Port to listen on / connect to |
| `DISPLAY`  | `:0`    | X11 display (Linux only)       |

Example — server on a custom port:

```bash
PORT=6000 docker compose up server
```

---

## How It Works (Architecture)

```
QML View
   ↓
TransferViewModel   (MVVM bridge)
   ↓
TransferService     (file I/O, progress)
   ↓
IProtocol  ←  ProtocolFactory::create("TCP" | "UDP")
   ↓              ↓
TcpProtocol    UdpProtocol
```

**Factory Pattern** — `ProtocolFactory::create(name)` is the only place that knows about concrete protocol classes. Adding a new transport means implementing `IProtocol` and adding one line to the factory. Nothing else changes.

**Why separate TCP and UDP chunk sizes?**
UDP is datagram-based — each send is one atomic packet with a hard OS limit of ~65,500 bytes. The app sends 8 KB chunks over UDP and 64 KB chunks over TCP so packets always fit and files arrive uncorrupted.

---

## Project Structure

```
src/
├── protocol/
│   ├── IProtocol.h / .cpp        interface
│   ├── ProtocolFactory.h         Factory
│   ├── TcpProtocol.h / .cpp      TCP implementation
│   └── UdpProtocol.h / .cpp      UDP implementation
├── service/
│   └── TransferService.h / .cpp  file I/O, progress signals
├── viewmodel/
│   └── TransferViewModel.h/.cpp  Q_PROPERTY bridge to QML
├── main.qml                      UI
└── main.cpp                      entry point
└── resources.qrc                 resources
Dockerfile
docker-compose.yml
```
