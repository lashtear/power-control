This is a basic power control system for operating the reactors in
EB's BigReactors mod for Minecraft-Forge.

It's been updated to handle API changes from both BR and
ComputerCraft.

See the pid-control branch for Francois Snyman's nice PID temperature
control; this should be vastly more efficient whereas the master
branch still calculates control rod position as a linear response to
power cell fullness.

Todo:
* Support for actively-cooled reactors and multiple
  independently-controllable turbines with variable RPM efficiency
  bands
* Better interface and documentation
* Support OpenComputers
