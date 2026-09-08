# ConsolePortLK

This AddOn is the backported version of [ConsolePortLK]([https://github.com/seblindfors/ConsolePort](https://github.com/leoaviana/ConsolePortLK)) 1.5.0-rc2, which is itself a fork of [ConsolePort](https://github.com/seblindfors/ConsolePort) 1.9.17, for World of Warcraft - Mists of Pandaria legacy client Version 5.4.8 (18414).<br /><br />

Beware that the World of Warcraft 5.4.8 client is old and it's no longer supported, this project has been created only for learning purposes (Lua programming).<br/><br/>

----------------------------------
----------------------------------
The rest of the README has been left as is from the original ConsolePortLK git.
----------------------------------
----------------------------------
----------------------------------




## Differences between ConsolePortLK vs ConsolePort 1.9.17

1. ConsolePortLK is a port to work on a World of Warcraft Lua API older than it supports (WoW 3.3.5a 12340).
2. Implemented workarounds for missing WoW API functions needed for this addon to work.

The original project is here: https://github.com/seblindfors/ConsolePort

This project is not affiliated in anyway with the original project, please do not ask the author of ConsolePort about issues regarding this version.

<br />

<h2>What is ConsolePorLK?</h2>
ConsolePortLK is an interface add-on for World of Warcraft that will give you a handful of nifty features
in order to let you play the game on a controller - without inconvenience.
<br/><br/>

Consisting of several modules, ConsolePortLK is a fully-fledged solution to handling all the quirks in a game where gamepad support was not intended,
including interface navigation, custom-tailored UI elements to assist in gameplay. You will need a controller mapping software to use this AddOn.
the original project used a app called WoWmapper which already did the mapping automatically, I completely rewrote it and launched **[WoWpadX](https://github.com/leoaviana/WoWpadX)**. A SDL3 based keyboard mapping software made to have a better integration with the Wrath of the Lich King (3.3.5a) and controller compatibility, however it's not mandatory to have it, you can use any controller mapping software.

## Screenshots:

<a href="https://user-images.githubusercontent.com/54692677/138369605-3ba273e8-598c-4549-9826-a4edc5411a3e.png">
<img src="https://user-images.githubusercontent.com/54692677/138370327-3c0b24b0-9ea5-4d90-bcf4-eb4638217f00.png" align="right" width="48.5%">
</a>
<a href="https://user-images.githubusercontent.com/54692677/138370446-ceae8a27-5276-4888-94b4-b747a8e1ed40.png">
<img src="https://user-images.githubusercontent.com/54692677/138370452-ddfb95dc-aa13-419d-bf03-4e2502a8a3bb.png" width="48.5%">
</a>

<a href="https://user-images.githubusercontent.com/54692677/138370582-5f14f0e2-9bd7-4980-ac3b-4155e30b70df.png">
<img src="https://user-images.githubusercontent.com/54692677/138370592-054fe76a-4b55-4da0-996a-8bb68118f692.png" align="right" width="48.5%">
</a>
<a href="https://user-images.githubusercontent.com/54692677/138370708-f074085d-9396-4c3c-8bb4-3a731ea261b9.png">
<img src="https://user-images.githubusercontent.com/54692677/138370714-fe06daba-ca0e-49af-97f9-e8e5e2ffd5ca.png" width="48.5%">
</a>

<a href="https://user-images.githubusercontent.com/54692677/138371330-0a63a2ca-05e6-4707-b96a-c73c841f5955.png">
<img src="https://user-images.githubusercontent.com/54692677/138371293-e03b7df5-b74e-4dba-abd2-0aa0eea5a2d6.png" align="right" width="48.5%">
</a>
<a href="https://user-images.githubusercontent.com/54692677/138371431-185684b8-f1f4-4d22-af17-47716daa1703.png">
<img src="https://user-images.githubusercontent.com/54692677/138371373-c0a53844-710b-4fbe-90bc-261b5b7cd016.png" width="48.5%">
</a>


## Installation:

1. Download **[Latest Version](https://github.com/leoaviana/ConsolePortLK/releases/latest)**
2. Unpack the Zip file
3. Copy (or drag and drop) all of the extracted folders (ConsolePort, ConsolePortBar, etc.) into your Wow-Directory\Interface\AddOns
4. Download **[WoWpadX](https://github.com/leoaviana/WoWpadX)**
5. Start WoWpadX and connect your controller.
5. Restart WoW

## Commands:

    /cp               Show all addon commands in the chatbox
    /cp actionbar     Modify controller actionbar
    /cp config        Open the configuration panel
    /cp cvar          (Advanced) list of console variables
    /cp help          Help & Tutorials
    /cp recalibrate   Recalibrate your controller
    /cp resetall      Full addon reset (irreversible)
    /cp type          Change controller type

## FAQ:

### I would like to report a bug. What i need to do?
Make sure you're using the latest version of [ConsolePort](https://github.com/leoaviana/ConsolePortLK/releases/latest)
<br />
Describe your issue in as much detail as possible.
<br />
If your issue is graphical, please take some screenshots to illustrate it.
<br />
What were you doing when the problem occurred?
<br />
Explain how people can reproduce the issue.
<br />
<br />
### Can you port this to 2.4.3 or older?
ConsolePort relies mostly on [RestrictedEnvironment](https://wowwiki-archive.fandom.com/wiki/RestrictedEnvironment) functions and [SecureHandlers](https://wowwiki-archive.fandom.com/wiki/SecureHandlers), most of those we're implemented into the game client after patch 3.0, so <b>no.</b> I'm not saying that it is completely impossible to port because I don't know but as far I know there is no alternatives to RestrictedEnvironment on older clients, it seems like that there is an alternative to SecureHandlers implemented in patch 2.0 but the documentation about it is scarce and I do not have any interest in porting it to older versions.
<br />
<br />
### The AddOn does not work on X client. Why?
ConsolePortLK has only been made taking in consideration default WoW API for 3.3.5a, if you are trying to use this AddOn in a heavily modded client it may work, but you can't be surprised if it doesn't since it relies heavily on sensitive secure APIs, changes in these might break everything.<br/><br/>

If somehow it doesn't work for you in a customized client, don't expect fast changes in this AddOn just to support it unless someone with enough interest send pull requests fixing these issues when they happen, because customized clients can be a moving target and may get new modifications that break old stuff.

### WoWpadX is not recognizing WoW as a running process: 
Due to how non-steam games are added, or how Proton compatibility works, it may be difficult to get WoWPadX working as intended on Steam/Steam deck/SteamOS. If this is the case, try each option until one works for you.

Before you try the follow, make sure WoWpadX and the WoW.exe are on the same Proton compatability setting (or Wine Prefix). You may have to try different settings until both work on the same Proton/Wine prefix setting.

#### 1) WoWPadX Launch Options Command Line

With WoWpadX as non steam game, go to properties of the game and find the `Launch Options` dialog, and put the command line argument -l and specify the path of the wow executable, it should launch the executable in the same prefix and recognize it immediately.

Example Usage: `WoWpadX.exe -l "/Path/To/WoW.exe"`. If this option does not work, try the next.

#### 2) WoW.exe Launch Options

Go to the properties of your added non steam game for the WoW executable. In the `Launch Options`, add this:

`PROTON_REMOTE_DEBUG_CMD="/Absolute Path/To Your WoWPadX Executable/here" %command%`

Exampel Usage: `PROTON_REMOTE_DEBUG_CMD="/home/deck/Games/WoW/3.3.5a/WoW.exe" %command%`

#### 3) Steam Game Controller Layout

If non of the above options work, this is the last resort.

- Name your WoW game `World of Warcraft: WotLK` in Steam.
- Go to Controller Layout: In Template, Community or Search and look for the template: `Gamepad leoaviana ConsolePortLK` by Prrg.

If the layout is not showing up, make sure to select `Show All Layouts`. and look for it again.

Apply the layout.

