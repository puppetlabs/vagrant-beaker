# Beaker as a Vagrant plugin

This provides a bridge between Puppetlabs' test harness Beaker and Vagrant

## Installation

There is a gem available in the pkg/ directory for internal consumption.

```bash

  git clone git@github.com:puppetlabs/vagrant-beaker.git
  cd vagrant-beaker
  vagrant plugin install pkg/vagrant-beaker-0.0.1.gem
  vagrant add box delivery examples/box/delivery.box
  cp examples/Vagrantfiles/Vagrantfile.example1 ./Vagrantfile

```

Then either update either update the username and password sections in the Vagrantfile or export them as environment variables like:

```bash

  export VSPHERE_USER='justin@puppetlabs.com'
  export VSPHERE_PASSWORD='myP@$$w0rd'

```

Finally, assuming you have correct permissions withing vSphere you should be able to:

```bash

  vagrant up --provider=delivery

```

And log in via:

```bash

  vagrant ssh master

```

## Usage

TODO: Write usage instructions here

The vagrant commands `up`, `destroy`, `status`, and `halt` should work relatively correctly at this point....

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
