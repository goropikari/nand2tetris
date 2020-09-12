# VMTranslator

Usage
```
cd VMTranslator

julia --project=.
using Pkg
Pkg.instantiate()

using VMTranslator
VMTranslator.translate("/path/to/vmfile.vm", "/path/to/out.asm")
```
