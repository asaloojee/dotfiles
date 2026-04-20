{...}: {
  home.file = {
    ".pi/agent/settings.json" = {
      source = ../../.pi/agent/settings.json;
      force = true;
    };
    ".pi/agent/AGENTS.md" = {
      source = ../../.pi/agent/AGENTS.md;
      force = true;
    };
    ".pi/agent/extensions/safety-gate.ts" = {
      source = ../../.pi/agent/extensions/safety-gate.ts;
      force = true;
    };
  };
}
