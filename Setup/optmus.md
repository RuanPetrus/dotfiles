# EnvyControl 

Program who helps you manage your graphics in laptops
To install
```sh
yay -S envycontrol
```

To switch between implementations
```sh
envycontrol --switch integrated
envycontrol --switch nvidia
envycontrol --switch hybrid
```

To open an application in hybrid mode with nvidia
```sh
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <program>
```


