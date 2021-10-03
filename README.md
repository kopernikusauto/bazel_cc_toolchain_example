
# Fixed by correcting linker args

I was using `-l:libstdc++.a` which apparently works in most cases.

I replaced that with `-Bstatic -lstdc++ -Bdynamic`.


## Original problem statement


This repo illustrates a simple custom toolchain config... with a problem:

- It's possible to link and run C++ libraries and programs.

- It's also possible ot link and run Rust libaries and programs.

- *But it isn't possible to link a C++ library with a Rust binary.*


_If you use your host toolchain it should actually work though._

When attempting to link a C++ library to a rust target the linker is unable to resolve any C++ symbols.


---

To test with the host toolchain, comment out the last two lines of WORKSPACE that look like this:

```
load("//build:toolchains.bzl", "register_all_toolchains")
register_all_toolchains()
```

After that, Bazel should configure a cc toolchain based on your system.

