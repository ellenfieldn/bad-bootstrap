# bad-bootstrap

A hodgepodge of random junk I've used to setup my systems

You really shouldn't use this. It's a mess.

On Windows machines, I generally dump things in `c:\tools` out of laziness.

## (dis)organization Notes

I currently have all this stuff in `c:\tools`. Shocking, I know, given the above note.

- `AutoHotKey\` - AutoHotKey v2 scripts. I don't actually use these, but I'm pretty sure I wrote them for a reason.
- `bootstrap\` - Random scripts that I run to set things up. Little rhyme or reason to be found
- `config\` - OhMyPosh config. Surely there's a better place for this!
- `pwsh\` - Misc powershell scripts that I use. Also my powershell profile.
- `utility\` - I think this has an older version of my powershell profile + some random scripts to test out profile-related things.
- `wsl\` - A really incomplete collection of stuff to setup WSL.
- `choco.txt` - Some chocolatey packages I installed at some point....

## TODO

- Powershell profile is not portable at all! This should move to my dotfiles repo and get some love.
- wtf is this junk in `utility`

## Other things

- There should be a folder in C:\tools\portable that should contain

```
c:\tools\portable\micro\ 
c:\tools\portable\container-diff.exe 
c:\tools\portable\docker-buildx.exe 
c:\tools\portable\jq.exe 
c:\tools\portable\kustomize.exe 
c:\tools\portable\micro.exe 
c:\tools\portable\nuget.exe 
c:\tools\portable\Procmon.exe 
c:\tools\portable\Procmon64.exe 
c:\tools\portable\Procmon64a.exe 
c:\tools\portable\puttygen.exe 
c:\tools\portable\testkube.exe
```