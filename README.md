hiera-eyaml-gpg
===============

GPG encryprion backend for the [hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml) module.

Motivation
----------

The default PKCS#7 encryption scheme used by hiera-eyaml is perfect if only simple
encryption and decryption is needed.

However, if you are in a sizable team it helps to encrypt and decrypt data with multiple
keys. This means that each team member can hold their own private key and so can the puppetmaster.
Equally, each puppet master can have their own key if desired and when you need to rotate 
keys for either users or puppet masters, re-encrypting your files and changing the key everywhere
does not need to be done in lockstep.
