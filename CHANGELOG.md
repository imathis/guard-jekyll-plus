# Changelog

### 1.0.0
- Initial release. A nice guard watcher for Jekyll projects.

### 1.1.0
- Added support for Jekyll serve.

### 1.1.1
- Improved colorized output.
- Rescued errors kill the Jekyll WEBrick server.

## 1.1.2

New config options

- `config_hash` allows passing a config hash instead of an array of config files.
- `silent` allows you to prevent all output other than exception errors.

### 1.2.0

**Changed** Now you must use jekyllplus in your guard file. Check the readme for updates.

- Changed guard name to jekyllplus to avoid issues with Guard Jekyll.
- Fixed installation of template guardfile
- Improved handling of Jekyll WEBrick server

### 1.2.1

- Removed accidental debugging output.

### 1.2.2

- Copy and remove ignore changes in directories beginning with an underscore.
- Improved output for Jekyll build.

