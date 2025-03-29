# gridfinity.bosl2
An [OpenSCAD](https://openscad.org/) library including modules for generate attachable gridfinity objects usng the [BOSL2](https://github.com/BelfrySCAD/BOSL2) library.

# Usage
Copy the gridfinity.bosl2.scad file to one of your local OpenSCAD library directories.

Add an include for the library:

    include <gridfinity.bosl2.scad>

Call the gridfinity_base module:

    gridfinity_base([1,1,42]);

The resulting model will appears as:
![Resulting model](https://github.com/melance/gridfinity.bosl2/blob/main/Images/gridfinity_base.1x1x42.png)
