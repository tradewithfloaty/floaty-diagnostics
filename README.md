# Floaty diagnostics

Support scripts for [Floaty](https://tradewithfloaty.com). The code is public.
You can read any of it on this page before you run it.

The scripts do not install, change or delete anything, and they do not send your
data anywhere. They print a report in your terminal. You decide what to send us.

## macOS

[`macos/floaty-diag.sh`](macos/floaty-diag.sh) checks why Floaty Core fails to start.

Open Terminal: press Command and Space together, type `Terminal`, press Enter.

Copy the line below, paste it into Terminal, and press Enter:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/tradewithfloaty/floaty-diagnostics/main/macos/floaty-diag.sh)"
```

Then copy everything it prints and send it to us. The report shows your macOS
version, your username, and the permissions on Floaty's files.
