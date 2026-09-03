{ config, ... }:

let
  agentSock = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;

    # Disable the built-in defaults to avoid the warning
    enableDefaultConfig = false;

    # "*" is emmitted last regardless of DAG order, so first-match-wins
    settings."*" = {
      IdentityAgent = agentSock;
      AddKeysToAgent = "no"; # 1Password owns keys, not ssh agent
      ForwardAgent = false;
      Compression = false;
      HashKnownHosts = false;
      ServerAliveInterval = 3;
      ServerAliveCountMax = 3;
    };
  };

  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Work/Home"

    [[ssh-keys]]
    vault = "Private"
  '';

  home.sessionVariables.SSH_AUTH_SOCK = agentSock;
}
