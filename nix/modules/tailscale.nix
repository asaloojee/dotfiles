{pkgs, ...}: {
  launchd.daemons.tailscaled = {
    serviceConfig = {
      ProgramArguments = ["${pkgs.tailscale}/bin/tailscaled" "--state" "/Library/Tailscale/tailscaled.state"];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/tailscaled.log";
      StandardErrorPath = "/var/log/tailscaled.log";
    };
  };
}
