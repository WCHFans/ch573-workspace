CH573 Bazel Workspace
======

CH573/CH571 are manufactured by WCH, a cool company from Nanjing, China. **If dear WCH can open source their isptool, that would be so great.**

**WARNING:** This project is at a very early stage, may have unknown bugs. Be careful when you use it in production, anyway, caveat emptor.

It seems that cross-compiling fails when your executor is `sandbox`, so we use `local` instead.
Here's the compile command, if you want verbose output, please append `-s --verbose_failures --config=riscv --spawn_strategy=local` after your command.

```bash
bazel build //embedded:firmware
```

## Things you may concern

1. It was only tested on Ubuntu 20.04, will be tested on macOS, won't work on Windows.
1. Arduino API? Yes, definitely that's one of the objectives of this project.
1. More examples? **↓ ↓ ↓ ↓ ↓**
1. Submitting PR? DEFINITELY WELCOME!

## References
* [CH573/CH571 Datasheet](http://www.wch.cn/downloads/CH573DS1_PDF.html)
