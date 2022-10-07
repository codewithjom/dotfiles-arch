-- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

-- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.Place
import XMonad.Hooks.WindowSwallowing

-- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- Set colorscheme for xmobar 
-- See more colors in lib/Colors
import Colors.Nord

myFont :: String
myFont = "xft:Roboto Mono Nerd Font:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask        -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"    -- Sets default terminal

myBrowser :: String
myBrowser = "qutebrowser"   -- Sets qutebrowser as browser

myEmacs :: String
myEmacs = "emacs"  -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = "emacs"  -- Sets emacs as editor

myFileManager :: String
myFileManager = "pcmanfm"   -- Sets pcmanfm as file manager

myScreenshot :: String
myScreenshot = "scrot 'screenshot-%s.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'"

myBorderWidth :: Dimension
myBorderWidth = 2           -- Sets border width for windows

myNormColor :: String       -- Border color of normal windows
myNormColor   = "#01060E"   -- This variable is imported from Colors.THEME

myFocusColor :: String      -- Border color of focused windows
myFocusColor  = "#90E1C6"   -- This variable is imported from Colors.THEME

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawn ("sxhkd -c $HOME/.config/xmonad/lib/scripts/sxhkdrc")
  spawn ("bash ~/.config/polybar/launch.sh --forest")
  -- spawn ("killall trayer")
  -- spawn ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ colorTrayer ++ " --height 22")

  spawnOnce ("lxsession")
  spawnOnce ("picom --experimental-backends -b")
  spawnOnce ("nm-applet")
  spawnOnce ("volumeicon")
  spawnOnce ("xsetroot -cursor_name left_ptr")
  spawnOnce ("pamac-tray")
  -- spawnOnce ("blueberry-tray")
  spawnOnce ("conky -c ~/.config/xmonad/lib/scripts/conkyrc")

  spawnOnce "nitrogen --set-scaled --restore &"

  setWMName "LG3D"

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- There are bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 5
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ simplestFloat

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:FantasqueSansMono Nerd Font:bold:size=50"
    , swn_fade              = 0.3
    , swn_bgcolor           = "#001b21"
    , swn_color             = "#839496"
    }

-- The layout hook
myLayoutHook = avoidStruts 
               $ mouseResize 
               $ windowArrange 
               $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout 
                 where 
                   myDefaultLayout = withBorder myBorderWidth tall ||| noBorders monocle  ||| floats 

-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = ["DEV", "WEB", "SYS", "DOC", "VIR", "MSG", "MUS", "VID"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ className =? "confirm"            --> doCenterFloat
     , className =? "file_progress"      --> doCenterFloat
     , className =? "dialog"             --> doCenterFloat
     , className =? "download"           --> doCenterFloat
     , className =? "error"              --> doCenterFloat
     , className =? "Gimp"               --> doCenterFloat
     , className =? "notification"       --> doCenterFloat
     , className =? "pinentry-gtk-2"     --> doCenterFloat
     , className =? "splash"             --> doCenterFloat
     , className =? "toolbar"            --> doCenterFloat
     , className =? "Yad"                --> doCenterFloat
     , title =? "Oracle VM VirtualBox Manager"  --> doFloat
     , title =? "Mozilla Firefox"        --> doShift ( myWorkspaces !! 1 )
     , className =? "Brave-browser"      --> doShift ( myWorkspaces !! 1 )
     , className =? "Brave-browser-dev"  --> doShift ( myWorkspaces !! 1 )
     , className =? "Min"                --> doShift ( myWorkspaces !! 1 )
     , className =? "qutebrowser"        --> doShift ( myWorkspaces !! 1 )
     , className =? "Vimb"               --> doShift ( myWorkspaces !! 1 )
     , className =? "Tor Browser"        --> doShift ( myWorkspaces !! 1 )
     , className =? "Chromium"           --> doShift ( myWorkspaces !! 1 )
     , className =? "Google-chrome"      --> doShift ( myWorkspaces !! 1 )
     , className =? "jetbrains-idea-ce"  --> doShift ( myWorkspaces !! 2 )
     , className =? "jetbrains-studio"   --> doShift ( myWorkspaces !! 2 )
     , className =? "Subl"               --> doShift ( myWorkspaces !! 2 )
     , className =? "DesktopEditors"     --> doShift ( myWorkspaces !! 3 )
     , className =? "VirtualBox Manager" --> doShift ( myWorkspaces !! 4 )
     , className =? "Virt-manager"       --> doShift ( myWorkspaces !! 4 )
     , className =? "discord"            --> doShift ( myWorkspaces !! 5 )
     , className =? "Thunderbird"        --> doShift ( myWorkspaces !! 5 )
     , className =? "Spotify"            --> doShift ( myWorkspaces !! 6 )
     , className =? "Gimp"               --> doShift ( myWorkspaces !! 8 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ]

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
    -- KB_GROUP Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")       -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")         -- Restarts xmonad
        , ("M-x", io exitSuccess)                     -- Quits xmonad

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTerminal))
        , ("M-b", spawn (myBrowser))
        , ("M-n", spawn (myEditor))
        , ("M-S-<Return>", spawn (myEmacs))
        , ("M-S-f", spawn (myFileManager))
        , ("C-<Return>", spawn (myScreenshot))
        , ("M-S-c", spawn "killall conky")

    -- KB_GROUP Kill windows
        , ("M-q", kill1)       -- Kill the currently focused client
        , ("M-S-q", killAll)   -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
        , ("M-.", nextScreen)  -- Switch focus to next monitor/projector
        , ("M-,", prevScreen)  -- Switch focus to prev monitor/projector

    -- KB_GROUP Floating windows
        , ("M-f", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- KB_GROUP Window spacing
        , ("C-M-j", decWindowSpacing 4)
        , ("C-M-k", incWindowSpacing 4)
        , ("C-M-h", decScreenSpacing 4)
        , ("C-M-l", incScreenSpacing 4)

    -- KB_GROUP Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- KB_GROUP Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- KB_GROUP Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Expand vert window width

        ]
-- END_KEYS

main :: IO ()
main = do
    xmproc0 <- spawnPipe ("") -- Add comment to use the bar below
    -- xmproc0 <- spawnPipe ("xmobar -x 0 $HOME/.config/xmonad/lib/scripts/xmobarrc")
    -- xmproc1 <- spawnPipe ("xmobar -x 1 $HOME/.config/xmonad/lib/scripts/xmobarrc")
    -- $ ewmhFullscreen (add this below to apply fullscreen)
    xmonad $ ewmh  $ docks $ def
        { manageHook         = placeHook simpleSmart <+> myManageHook <+> manageDocks
        , handleEventHook    = swallowEventHook (className =? "Alacritty" <||> className =? "XTerm") (return True)
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP $ xmobarPP
              -- XMOBAR SETTINGS
              { ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                              -- >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
                -- Current workspace
              , ppCurrent = xmobarColor color06 "" . wrap "[" "]"
                -- Visible but not current workspace
              , ppVisible = xmobarColor color06 "" . clickable
                -- Hidden workspace
              , ppHidden = xmobarColor color05 "" . wrap "*" "" .clickable
                -- Hidden workspaces (no windows)
              , ppHiddenNoWindows = xmobarColor color05 ""  . clickable
                -- Title of active window
              , ppTitle = xmobarColor colorFore "" . shorten 70
                -- Separator character
              , ppSep =  "<fc=" ++ color09 ++ "> <fn=1>|</fn> </fc>"
                -- Urgent workspace
              , ppUrgent = xmobarColor color02 "" . wrap "!" "!"
                -- Adding # of windows on current workspace to the bar
              , ppExtras  = [windowCount]
                -- order of things in xmobar
              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
              }
        } `additionalKeysP` myKeys
