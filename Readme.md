# vagrant-sparseimage

`vagrant-sparseimage` is a [Vagrant](http://vagrantup.com) plugin which automatically creates and mounts a sparseimage for the guest system to share. This allows alternative filesystems to be used between the host and the guest (eg. journaled, case sensitive).

The image can be browser from OSX Finder and is completely configurable. It can be unmounted automatically when the guest is halted, or left mounted for other uses. When the Vagrant guest is destroyed, the image can optionally be destroyed too.

## Dependencies

Only runs in OSX. Requires vagrant 0.9.4 or later (including 1.0). Does not currently support Vagrant 1.1+ - the plugin API changed.

## Installation

Since Vagrant v1.0.0, the preferred installation method is using prebuilt packages or installers.

If you installed vagrant that way, you need to use vagrant's gem wrapper:

```bash
$ vagrant gem install vagrant-sparseimage
```

If you installed vagrant using RubyGems, use:

```bash
$ gem install vagrant-sparseimage
```

## Configuration

TODO - document required attrs.

## Building

If you installed vagrant using RubyGems, use:

```bash
$ gem build vagrant-sparseimage.gemspec
```

If you installed Vagrant with a prebuilt package or installer, you need to use Vagrant's gem wrapper:

```bash
$ vagrant gem build vagrant-sparseimage.gemspec
```

## Configuration / Usage

To enable the plugin you need to add the following to your `Vagrantfile`:

```ruby
Vagrant::Config.run do |config|
    # set to true to enable plugin
    config.sparseimage.enabled = true

    # to set the image volume name; the default is the name of the directory containing the
    # Vagrantfile
    #config.sparseimage.volume_name = "Vagrant Image"

    # to set the guest mount point for the image; the default is the name of the directory containing
    # the Vagrantfile (eg. /vagrant_dir)
    #config.sparseimage.vm_mountpoint = "/www"

    # to set the image filename; the default is .<vm name>.sparseimage
    #config.sparseimage.image_filename = ".amazingimagefile"

    # to set the image maximum size in gigabytes; the first time "vagrant up" the system you will be prompted
    #config.sparseimage.image_size = 5

    # to set the image file system; the default is JHFS+X
    #config.sparseimage.image_fs = "HFS+"

    # to set the image type between SPARSE and SPARSEBUNDLE; the default is SPARSE
    #config.sparseimage.image_type = true

    # to disabled auto-unmount; to stop "vagrant halt" unmounting the image
    #config.sparseimage.auto_unmount = false

    # to set NFS share options; default is true
    #config.sparseimage.nfs_options = ["ac","acregmin=1"]
end
```

### Config options

* `enabled` : Turns on sparseimage support.
* `volume_name`: Set the volume name of the image to be mounted.
* `vm_mountpoint`: The location in the guest the image will be mounted.
* `image_filename`: The image filename.
* `image_size`: The maximum image file system size.
* `image_fs`: The image file's file system.
* `auto_unmount`: Disable the auto unmounting of the image file after the guest is halted.


