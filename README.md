Reference implementation for a git-aware deployment process.

This script will:

* clone the repository on the local machine or fetch if it already exists
* reset hard to the specified revision
* carefully update the submodules
* rsync the checkout (minus .git/) to the deployment directory
* update the symlink
* restart the webserver

Note that this is a reference implementation -- it's to help you build this
logic into your own deployment process, not to be a standalone deployment
script.
