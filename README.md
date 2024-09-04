Kontrol Workshop for Mantle Devs
-------------------------

In this repo you'll find the examples covered in the Kontrol Dev Tooling Session for Mantle devs.

## Getting Kontrol

We recommend installing Kontrol via the K framework package manager, `kup`.

To get `kup` and install Kontrol:
```shell
bash <(curl https://kframework.org/install)
kup install kontrol
```

For more information you can visit the [`kup` repo](https://github.com/runtimeverification/kup) and the [`kup` cheatsheet](https://docs.runtimeverification.com/kontrol/cheatsheets/kup-cheatsheet).

## Using Docker Instead

We also provide a docker image with all the commands already executed in case you want to walk through the instructions provided but don't want to compute the examples yourself.

To get the docker image and run a bash shell do
```shell
docker run -it ghcr.io/runtimeverification/kontrol/kontrol-mantle-workshop
```

### Kontrol usage

To build the examples, run the following command in the root of this repo:
```shell
kontrol build
```

Then, to run all proofs (functions starting from `test`, `prove`, or `check`), run:
```shell
kontrol prove
```

You can also run several proofs in parallel by using the `-jN` flag, where `N` is the number of parallel processes you want to run:
```shell
kontrol prove -j7
```

To run a specific proof, you can provide the name of the function or a prefix as an `--mt` argument:
```shell
kontrol prove --mt PortalTest.test_withdrawalPaused
```

Both `kontrol prove` and `kontrol build` invocations are parametrized by the [kontrol.toml](kontrol.toml) file.

## Documentation, Socials and Posts

Have more appetite for formal verification and Kontrol? The following resources will sort you out!

### Kontrol ecosystem

Get to know Kontrol more in depth. Open a PR or an issue!

- [Kontrol documentation](https://docs.runtimeverification.com/kontrol/cheatsheets/kup-cheatsheet)
- [Kontrol repo](https://github.com/runtimeverification/kontrol)

### Socials

You can reach us on any of these platforms. We'll answer any questions and provide guidance throughout your Kontrol journey!

- [Telegram](https://t.me/rv_kontrol)
- [Discord](https://discord.com/invite/CurfmXNtbN)
- [Twitter/X](https://x.com/rv_inc)

### Blog Posts

Want to learn more about Kontrol, formal verification, and the cool things we do? Read any of these posts!

- [Kontrol 101](https://runtimeverification.com/blog/kontrol-101)
- [Why does Formal Verification work?](https://runtimeverification.com/blog/formal-verification-lore)
- [Optimism's pausability system verification](https://runtimeverification.com/blog/kontrol-integrated-verification-of-the-optimism-pausability-mechanism)