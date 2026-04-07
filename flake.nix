{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      git-hooks,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        git-hooks.flakeModule
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          devShells.default = pkgs.mkShell {
            packages = config.pre-commit.settings.enabledPackages;
            buildInputs = with pkgs; [
              packer
              libisoburn
              powershell
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}

              pwsh -c 'Install-Module -Name PSScriptAnalyzer -Scope CurrentUser'
            '';
          };

          pre-commit = {
            settings = {
              package = pkgs.prek;
              hooks = {
                # Security checks
                trufflehog.enable = true;
                detect-private-keys.enable = true;
                check-added-large-files.enable = true;

                check-case-conflicts.enable = true;
                end-of-file-fixer.enable = true;
                trim-trailing-whitespace.enable = true;
                mixed-line-endings.enable = true;
                fix-byte-order-marker.enable = true;

                shellcheck = {
                  enable = true;
                  excludes = [ "\\.envrc$" ];
                };
                check-executables-have-shebangs.enable = true;
                check-shebang-scripts-are-executable = {
                  enable = true;
                  excludes = [ "\\.envrc$" ];
                };

                check-json.enable = true;

                terraform-format.enable = true;
                terraform-validate.enable = true;

                actionlint.enable = true;

                psscriptanalyzer = {
                  enable = true;
                  name = "PSScriptAnalyzer";
                  description = "Run PSScriptAnalyzer on PowerShell scripts";
                  entry =
                    let
                      script = pkgs.writeShellScript "psscriptanalyzer" ''
                        set -e
                        for file in "$@"; do
                          ${pkgs.powershell}/bin/pwsh -NoProfile -NonInteractive -Command "Invoke-ScriptAnalyzer -EnableExit -Path '$file'"
                        done
                      '';
                    in
                    "${script}";
                  files = "\\.(ps1|psm1|psd1)$";
                  language = "system";
                  pass_filenames = true;
                };
              };
            };
          };
        };
    };
}
