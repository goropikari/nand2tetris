# VMTranslator

Usage
```
cd VMTranslator

julia --project=.
using Pkg
Pkg.instantiate()

using VMTranslator
VMTranslator.translate("/path/to/vmfile.vm")

# or

VMTranslator.translate("/path/to/vmfile_dir")
```
