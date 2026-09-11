
-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
  hl.exec_cmd("wal -R && mkdir -p ~/.config/opencode/themes ~/.config/quickshell ~/.config/bat/themes && ln -sfn ~/.cache/wal/opencode-pywal.json ~/.config/opencode/themes/pywal.json && ln -sfn ~/.cache/wal/quickshell-colors.qml ~/.config/quickshell/PywalColors.qml && ln -sfn ~/.cache/wal/bat-pywal.tmTheme ~/.config/bat/themes/Pywal.tmTheme && bat cache --build >/dev/null 2>&1")
  hl.exec_cmd("command -v hypridle >/dev/null 2>&1 && hypridle")
  hl.exec_cmd("command -v fcitx5 >/dev/null 2>&1 && fcitx5 -d")
end)
