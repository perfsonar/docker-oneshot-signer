# Docker One-Shot Signer

Ths directory containsw a Dockerfile and supporting files to construct
Docker container images that sign all RPM or Debian packages in a
directory shared from the host system.  This activity is referred to
as a _Docker One-Shot Signing_ or _DOSS_.

The use case for DOSSes is to enable repositories to be easily signed
manually or as part of an automated process.


## Prerequisites

The following are required to run 

 * A POSIX-compliant shell
 * Docker or Podman with Docker compatibility installed
 * GPG (If a key is to be exported from a keyring.)

## Preparing to Sign

DOSS requires access to its containers, which are available on
`ghcr.io`.

There needs to be a directory containing an RPM or Debian repository
to be signed.  Usually, this will have been produced by Unibuild and
wil be named `unibuild-repo`.  DOSS will automatically select the
appropriate container to match the repository.

The key used to sign the packages in the repository can be one in your
GPG keyring or provided as a file that can be imported into GPG inside
the container during signing.  The passphrase for the key can be
provided on the command line (not recommended) or in a file
(recommended).


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
