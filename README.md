# Docker One-Shot Signer

Ths directory containsw a Dockerfile and supporting files to construct
Docker container images that sign all RPM or Debian packages in a
directory shared from the host system.  This activity is referred to
as a _Docker One-Shot Signing_ or _DOSS_.

The use case for DOSSes is to enable repositories to be easily signed
manually or as part of an automated process.


## Preparing to Sign

Other than Docker and access to the containers, the sole requirement
for a one-shot signing is a directory (called the _repository
directory_).  Usually, this will have been produced by Unibuild and
wil be named `unibuild-repo`.


## Signing Using a DOSS Container

### Quick Start

The recommended way to sign using DOSS is to run the `sign` script
directly from this repository:

```
$ curl -s https://raw.githubusercontent.com/perfsonar/docker-oneshot-signer/main/sign \
     | sh -s - [ OPTIONS ] REPO-PATH KEY
```

Where:

 * `REPO-PATH` is the path where the repository can be found.

 * `KEY` is the name of the key to be used in signing.  This will be
   exported from the invoking user's GPG keyring.  Prefix with `@` to
   read an exported, ASCII-armored key from a file (e.g.,
   `@/foo/bar`).


`OPTIONS` are:

 * `--passphrase P` - Use `P` as the passphrase for the key.  Prefix
   with `@` to read from a file (e.g., `@/foo/bar`).  If not provided,
   it will be assumed that the key has no passphrase.


For example:
```
$ curl -s https://raw.githubusercontent.com/perfsonar/docker-oneshot-signer/main/sign \
     | sh -s - --passphrase @/tmp/passphrase ./unibuild-repo 'Bob Smith'
```


The script will automatically determine whether the repository
contains RPMs and select the appropriate Docker container.
