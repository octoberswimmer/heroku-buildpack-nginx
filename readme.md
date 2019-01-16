# Heroku Buildpack: NGINX

# NOTICE: FORKED REPO - THE FOLLOWING DESCRIBES OUR CHANGES

ATK had previously forked a different [nginx repo](https://github.com/Americastestkitchen/heroku-buildpack-nginx). We have switched to this repo so that we can deploy on heroku-18 stack.

Our version of nginx includes a couple extra plugins (lua, geo) that required a new nginx binary. We run this binary in what this repo calls the `solo` mode but to keep our `kraken` scripts the same, we use the `start-nginx`.

## [Read the Original README](https://github.com/Americastestkitchen/heroku-buildpack-nginx)

# README CONTENTS FROM FORKED REPO (STILL RELEVANT HERE)

## Creating a new build

When this buildpack deploys on Heroku, the binary file corresponding to the currently configured stack (bin/nginx-heroku-18) is used. Rebuilding this binary can be done using the `scripts/build_nginx.sh` script. The script must be executed on a server that resembles the heroku stack as closely as possible. The steps below were used to create the latest build.

### Change the build file
If you are interested in creating a new build, you will need to modify the `scripts/build_nginx.sh` file.
1) Create a branch
2) Make your changes
3) Create the new build (see below)
4) Validate your build works on www-dev or www-staging (see below)
5) Open a PR
6) Merge PR

### Create a VM
1) Heroku describes their stacks in the [Stacks](https://devcenter.heroku.com/articles/stack) article, including the version of Linux required for each stack.
2) Go to the [Download Page for Ubuntu 18.04](http://releases.ubuntu.com/14.04/)
3) Download the [64-bit PC (AMD64) server install image](http://releases.ubuntu.com/18.04/) `.iso` file.
4) Using Virtual Machine, create a new Ubuntu Linux VM, allocating at least 10GB of space to a virtual HDD
5) Start the Virtual Machine - you will be asked to select a 'CD' - choose the `.iso` file you downloaded in step 3.
6) Complete the installation process for Ubuntu Server. This will take a while.

### Configure the VM
After you complete the install process, you will have a basic server. You will need to install the dependencies required for building nginx.

Ubuntu uses `apt-get` for most software installations. The following commands (and probably a few more that I forgot to document...sorry!) were required to successfully build nginx. These commands assume you are running as `root`,

# *NOTE*: All of these packages correlate to what is specified in the build script. If you are rebuilding because you are updating nginx to a newer version or compiling for a new version of Ubuntu, YMMV. If you change the versions of the software check the README for the various nginx modules. There are some good hints in there regarding compatibility for different scenarios.

```bash
$ sudo apt-get install git
$ sudo apt-get install build-essential libpcre3 libpcre3-dev
$ sudo apt-get install openssl libssl-dev libssl1.0.0 ca-certificates
$ sudo apt-get install lua5.1 liblua5.1.0 liblua5.1.0-dev
$ ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/liblua.so
$ sudo apt-get install libgeoip-dev
$ sudo apt-get install make
```

### Build nginx
```bash
$ cd ~
$ mkdir src
$ cd src
$ git clone https://github.com/Americastestkitchen/heroku-buildpack-nginx.git
$ cd heroku-buildpack-nginx
< make desired changes to scripts/build_nginx>
$ ./scripts/build_nginx ~/src/heroku-buildpack-nginx/bin/nginx-heroku-18
```
The above command will create a new binary file at `/tmp/nginx/sbin/nginx` and copy this file to the `bin` directory in local copy of the `heroku-buildpack-nginx` repository.

*NOTE* If you are changing heroku stacks, you will need to name the file based on the name of the heroku stack.

### Commit your changes

Since you'll be making the desired modifications on a Linux VM, you will need a secure way to authenticate to github when commiting your changes.

`$ git config --global user.email "<your-email>@americastestkitchen.com"`
`$ git config user.name "<Your Name Here>"`
`$ git add .`
`$ git commit -m 'really important new module added'`

Next, you'll need to create a [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) - selecting `repo` permissions so that you are allowed to push changes from the VM.

After you click the `Generate token` button, you should see your new token. Don't leave this screen until you perform the following:

`$ git push -u origin my-branch-with-changes`

Enter your github *username* when you see:
`$ Username for 'https://github.com': <your-username>`

Next, enter your new token when you should see the following:
`$ Password for 'https://<your-username>@github.com'`

Note: You are entering the token instead of your usual GH password.

### Test Your New nginx
1) In the Heroku dashboard, open `atk-kraken-dev`
2) In the Settings tab, delete the current buildpack
3) Create a new buildpack, `https://github.com/Americastestkitchen/heroku-buildpack-nginx.git#<your-branch-name-here>`
4) In the Deploy tab, deploy `master` or your current working branch
5) Test your new build, monitoring the logs for errors

### Deploy your working branch to production
Make absolutely sure your new build works. `kraken` sits in front of *everything*. So, if you screw it up, the whole site will be affected.

1) In the Heroku dashboard, open `atk-kraken-production`
2) In the Settings tab, delete the buildpack
3) Create a new buildpack, `https://github.com/Americastestkitchen/heroku-buildpack-nginx.git#<your-branch-name-here>`
4) In the Deploy tab, deploy `master` (or your `kraken` release branch)
5) Monitor the logs like a hawk

After the dust has settled and you are confident nginx is stable, you can merge your working branch to master. Then, change `atk-kraken-dev` and `atk-kraken-production` buildpack back to `https://github.com/Americastestkitchen/heroku-buildpack-nginx.git`. The change will go into effect the next time you deploy `kraken`.
