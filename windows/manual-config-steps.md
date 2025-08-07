# Detailed Configuration

Start by running `./config.ps1`

Do these things manually:

- Log into 1Password desktop app.
- Install 1Password browser extension.
- Log into 1Password browser extension.
- Log into Azure CLI.
- Log into Obsidian.

## Enable login with Security Key

- Under Sign-in options enable Security Key
- Ensure there is at least 1 backup key.
- Repeat for every security key

## Setup OnePassword

1. [Integrate 1Password CLI with the 1Password app](https://developer.1password.com/docs/cli/get-started/#step-2-turn-on-the-1password-desktop-app-integration)
1. Enable 1Password Developer Experience
1. [Configure VS Code to use 1Password](https://developer.1password.com/docs/vscode/#installation) and the appropriate vault
1. [Setup the 1Password SSH Agent](https://developer.1password.com/docs/ssh/get-started/?utm_medium=organic&utm_source=oph&utm_campaign=windows#step-3-turn-on-the-1password-ssh-agent) - test auth with `ssh -T git@github.com`
1. [Configure Git commit signing with SSH](https://developer.1password.com/docs/ssh/git-commit-signing/#step-1-configure-git-commit-signing-with-ssh)

## Install & Configure Fonts

Fonts will be downaloaded and installed by oh-my-posh.

All that's left is to configure Windows Terminal, VS Code, and Visual Studio to use them.

I use `FiraCode Nerd Font Mono`, but the examples use `MesloLGM`. For shorter line height, `MesloLGS` works.

### Windows Terminal

Once you have installed a Nerd Font, you will need to configure the Windows Terminal to use it. This can be easily done by modifying the Windows Terminal settings (default shortcut: CTRL + SHIFT + ,). In your settings.json file, add the font.face attribute under the defaults attribute in profiles:

```json
{
    "profiles":
    {
        "defaults":
        {
            "font":
            {
                "face": "MesloLGM Nerd Font"
            }
        }
    }
}
```

### Visual Studio Code

When using Visual Studio Code, you will need to configure the integrated Terminal to make use of the Nerd Font as well. This can be done by changing the Integrated: Font Family value in the Terminal settings (default shortcut: CTRL + , and search for Integrated: Font Family or via Users -> Features -> Terminal).

If you are using the JSON based settings, you will need to update the terminal.integrated.fontFamily value. Example in case of MesloLGM Nerd Font Nerd Font:

```json
"terminal.integrated.fontFamily": "MesloLGM Nerd Font"
```

### Visual Studio

When using Visual Studio, you will need to configure the integrated Terminal to make use of the Nerd Font as well. This can be done by opening the settings in Tools > Options > Fonts and Colors > Terminal and selecting a font like MesloLGM Nerd Font.

## Configure PowerShell Profile

Grab powershell profile from <https://github.com/ellenfieldn/bad-bootstrap/blob/main/pwsh/Microsoft.PowerShell_profile.ps1>
Add contents to powershell profile by running `code $PROFILE`
