# The Air Dirt Demo

Full assembler source for "The Air Dirt Demo" by The Senior Dads, which was released by The Senior Dads on the Atari Falcon 030 on the 12th August 1996.

## Specifications
* An Atari Falcon 030 with 4 megabytes of memory, TOS 4.04, and an internal hard drive.
* ... Alternatively, a decent emulator like Hatari, configured as above.
* Devpac 3 to assemble the code.
* Atomix packer or better to pack the executable.

## How to assemble
* Load "MAIN.S" into Devpac 3.
* Make sure settings are set to assemble to Motorola 68030!
* Assemble to executable file "MAIN.PRG".
* Rename exectuable to "AIR_DIRT.PRG".
* Pack "AIR_DIRT.PRG" with packer.
* Run "AIR_DIRT.PRG".

## Folders
* `AIR_DIRT.SED` - Original compiled demo and accompanying README.
* `GRAPHICS` - Graphics, in Degas Elite PI1 files and raw 16-bit 320x200 true colour images. There's also `CRAPFONT.DAT`, a 1 plane 32x16 font, and various `.ASA` files which contain screen configuration data.
* `INCLUDES` - Various macro and helpers code. Also includes `VSCROLL.S`, which contains the text for the credits at the end of the demo.
* `SOUND` - Sound and assoicated handling routines. `.MOP` files are modules packed using Delta Force's module packer, and depacked using `NMDEPACK.S`. `.RAP` files are packed RAW samples, depacked using `NDEPACK.S`. All other files are concerned with the module replay routines.
* `SRC_DATA` - Original versions of sound and graphics, as well as precalculation.
  * `DAT_PREP` - Creation of the 32x16 font in `MAKEFONT.S`, and creation of the "tunnel" effect in `TUNNEL.GFA`. (GFA v3)
  * `GFX` - Source graphics. Formats used are:
    * `.PC1` - Low res Degas Elite image.
    * `.IFF` - Low res Deluxe Paint image.
    * `.TPI` - Low res True Paint image.
    * `.GIF` - GIF files exported from the web site to be used in the "Presents..." screen.
  * `SOUND` - `.MOD` are Noisetracker compatible modules, `.RAW` is a raw sample .
