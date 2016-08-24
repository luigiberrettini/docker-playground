# Intro

A Docker image is a stack of read-only layers forming a base for a container’s root filesystem.
Each layer represents filesystem differences and the Docker storage driver provides a single unified view via UnionFS.
An image can be based on another one, making it possible to share layers:
```
╔═════════════════════════════╗             
║  ┌───────────────────────┐  ║             
║  │ image_2 R/O layer  #1 │  ║             
║  └───────────────────────┘  ║          ╔═════════════════════════════╗
║  ┌~~~~~~~~~~~~~~~~~~~~~~~┐  ║          ║  ┌───────────────────────┐  ║
║  ( image_2 R/O layer  #2 )──║──────────║─>│ image_1 R/O layer  #1 │  ║
║  └~~~~~~~~~~~~~~~~~~~~~~~┘  ║          ║  └───────────────────────┘  ║
║  ┌~~~~~~~~~~~~~~~~~~~~~~~┐  ║          ║  ┌───────────────────────┐  ║
║  ( image_2 R/O layer  #3 )──║──────────║─>│ image_1 R/O layer  #2 │  ║
║  └~~~~~~~~~~~~~~~~~~~~~~~┘  ║          ║  └───────────────────────┘  ║
║  ┌~~~~~~~~~~~~~~~~~~~~~~~┐  ║          ║  ┌───────────────────────┐  ║
║  ( image_2 R/O layer  #4 )──║──────────║─>│ image_1 R/O layer  #3 │  ║
║  └~~~~~~~~~~~~~~~~~~~~~~~┘  ║          ║  └───────────────────────┘  ║
║  ┌~~~~~~~~~~~~~~~~~~~~~~~┐  ║          ║  ┌───────────────────────┐  ║
║  ( image_2 R/O layer  #5 )──║──────────║─>│ image_1 R/O layer  #4 │  ║
║  └~~~~~~~~~~~~~~~~~~~~~~~┘  ║          ║  └───────────────────────┘  ║
║                             ║          ║                             ║
║           image_2           ║          ║           image_1           ║
╚═════════════════════════════╝          ╚═════════════════════════════╝
```

When a container is created, a new, thin, writable layer, is added on top of the underlying stack:
all changes made to the running container are written to this thin writable container layer, making it possible to safely share a single underlying image.
```
┌-------------------┐     ┌-------------------┐
│ R/W layer      C1 │ ... │ R/W layer      CN │
└-------------------┘     └-------------------┘
         ↕    ↕    ↕       ↕    ↕    ↕
        ╔═════════════════════════════╗
        ║   ┌─────────────────────┐   ║
        ║   │ image R/O layer  #1 │   ║
        ║   └─────────────────────┘   ║
        ║   ┌─────────────────────┐   ║
        ║   │ image R/O layer  #2 │   ║
        ║   └─────────────────────┘   ║
        ║   ┌─────────────────────┐   ║
        ║   │ image R/O layer  #3 │   ║
        ║   └─────────────────────┘   ║
        ║   ┌─────────────────────┐   ║
        ║   │ image R/O layer  #4 │   ║
        ║   └─────────────────────┘   ║
        ║                             ║
        ║        image:version        ║
        ╚═════════════════════════════╝
```

By using a copy-on-write approach, before modifying a file for the first time, a top-down search for it through the image layers is performed and a "copy-up" operation of the first copy found to the container’s writable layer is performed.
Large files, lots of layers, and deep directory trees can make the impact of the copy-up operation more noticeable.
Containers that write a lot of data will consume more space than containers that do not; in such cases, it is more appropriate to use a data volume, a specially-designated directory (within one or more containers) that bypasses the Union File System and persist data, independent of the container’s life cycle.

Image and container layers are located in the Docker host’s local storage area under `/var/lib/docker/`:
 - IMAGES in `/var/lib/docker/aufs/layers/`
 - CONTAINERS in `/var/lib/docker/containers`

All image layer IDs are cryptographic content hashes, whereas the container ID is a randomly generated UUID:
```
   ┌----------------------------------------------------┐
   │ 75bab0d54f3c (random UUID)   container layer   R/W │
   └----------------------------------------------------┘
       ↕    ↕    ↕    ↕    ↕    ↕    ↕    ↕    ↕    ↕
   ╔════════════════════════════════════════════════════╗
   ║  ┌──────────────────────────────────────────────┐  ║
   ║  │ a3ed95caeb02 (hash)     image layer      R/O │  ║
   ║  └──────────────────────────────────────────────┘  ║
   ║  ┌──────────────────────────────────────────────┐  ║
   ║  │ 0b7e98f84c4c (hash)     image layer      R/O │  ║
   ║  └──────────────────────────────────────────────┘  ║
   ║  ┌──────────────────────────────────────────────┐  ║
   ║  │ f157c4e5ede7 (hash)     image layer      R/O │  ║
   ║  └──────────────────────────────────────────────┘  ║
   ║  ┌──────────────────────────────────────────────┐  ║
   ║  │ 1ba8ac955b97 (hash)     image layer      R/O │  ║
   ║  └──────────────────────────────────────────────┘  ║
   ║                                                    ║
   ║                    ubuntu:15.04                    ║
   ╚════════════════════════════════════════════════════╝
```