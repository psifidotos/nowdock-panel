About
=====
This is a panel for Plasma 5 which is trying to implement a
mac style effect for its applets. It uses the Now Dock plasmoid
for its configuration and complements it as one single area
for which the user can add its applets. The applets as the user
windows are going to create a nice zoom effect on hovering.

Installation
============

**(no translations)**
- cd nowdockpanel
- plasmapkg -i .

**(with translations)**
- $ mkdir build
- $ cd build
- $ cmake -DCMAKE_INSTALL_PREFIX=/usr .. 
- $ make
- $ sudo make install

Now Dock Panel is now ready to be used from right-click menu in the Desktop

Translators
============
For translations you can use the **transifex.com** webpage using the link:

https://www.transifex.com/psifidotos/now-dock-panel/


Requirements  
------------
* Plasma >= 5.7.0
* Now Dock Plasmoid >= 0.3.0




