# pacman-windews

> a winget wrapper for arch btw users

# Dependencies :

- cmd

- winget installed, configured and usable

# Usage :

pacman.cmd [Command] [Packages]

Commands :
-S[yuis] [package] -> Install [package]
├── y -> update database
│     Tip : This is not required as winget will automatically do
├── u -> upgrade system
│     Tip : pacman.cmd -Su [package] to upgrade system then install [package]
├── i -> show information about [package]
└── s -> search for [package]
      Tip : pacman.cmd [package] to search for [package]

-Q[i] [package] -> Query [package]
└── i -> show information about an installed package
      Tip : provide no package will list installed package

-R [package] -> Uninstall [package]

-h, --help -> show this help message

-v -> verbose mode <!-- and tells you that mizuki is tuff -->

<sup><sub> Please dont be genderism Mizuki is very tuff </sub></sup>
