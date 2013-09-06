#!/bin/bash

gem uninstall hiera-eyaml-gpg
rake build
gem install pkg/hiera-eyaml-gpg
eyaml -v