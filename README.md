# packer_templates
Templates for packer generating vagrant boxes

# Usage

Download the ubuntu server iso image into the `iso/` folder then generate the image.

```bash
$ packer build vagrant-box.json
```

The image will be generated into the `output/` directory.
