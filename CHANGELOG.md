# Changelog

### 2.0.1 - 05-06-2015
- Fix: Guard init failure.
- Fix: Mishandling of paths triggered a SameFile argument error.

### 2.0.1 - 12-15-2014

- Changed guard template name for better compatibility with Guard's naming scheme.

### 2.0.0 - 12-15-2014

- Updated to work with Guard 2.x

### 1.4.10

- Now pointing to the latest compatible Guard release.

### 1.4.9

- Fix: Copying files ensures that there are files to copy before printing its message.

### 1.4.8

- Added a way to ignore Guard Stitch Plus's source files.

### 1.4.7

- Double checks that there are files to remove before proceeding and printing remove message.

### 1.4.6

- Rack is now actually optional (oops).

### 1.4.5

- Rack process is now succesfully killed on Guard stop

### 1.4.4

- Removed more debugging output. Srsly?

### 1.4.3

- Removed some debugging output

### 1.4.2

- Unescape URLs in Rack (support for non-ASCII URLs)

### 1.4.1

- Rack root is now configured by Jekyll 'destination' configuration

### 1.4.0

- Now allowing Rack server as an alternative to Jekyll's WEBrick server.
- Ships with an internal config for Rack, but users can override it in the guard config options.

### 1.3.0

- Changed guard name to jekyll_plus to help Guard properly init the Guardfile.

### 1.2.3

- Added configuration to change the message prefix for Guard UI 
- Added license to gemspec

### 1.2.2

- Copy and remove ignore changes in directories beginning with an underscore.
- Improved output for Jekyll build.

### 1.2.1

- Removed accidental debugging output.

### 1.2.0

**Changed** Now you must use jekyllplus in your guard file. Check the readme for updates.

- Changed guard name to jekyllplus to avoid issues with Guard Jekyll.
- Fixed installation of template guardfile
- Improved handling of Jekyll WEBrick server

## 1.1.2

New config options

- `config_hash` allows passing a config hash instead of an array of config files.
- `silent` allows you to prevent all output other than exception errors.

### 1.1.1
- Improved colorized output.
- Rescued errors kill the Jekyll WEBrick server.

### 1.1.0
- Added support for Jekyll serve.

### 1.0.0
- Initial release. A nice guard watcher for Jekyll projects.
