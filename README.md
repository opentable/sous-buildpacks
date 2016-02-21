# Sous buildpacks

Each directory in this repo contains an entire buildpack.

## What's in a buildpack?

A buildpack consists of a series of shell scripts which are run inside special build containers spun up by Sous. These containers have some features which make them ideal for building, more on that below. A single buildpack tells Sous how to build projects written using a particular stack. For example NodeJS, Ruby, C#, Java, ...

Each script in a buildpack performs a specific task, either doing something with, or providing some information about your project to Sous. Here are all the scripts each buildpack needs:

- `detect.sh` is a special case, and is the only script which gets executed outside of a container. It detects if this build pack knows how to build the project in your current directory
- `base.sh` is loaded before every script run inside the container, and can be used to perform any necessary setup tasks, such as moving files around, and setting environment variables etc.
- `test.sh` is used to invoke any unit tests your project has
- `compile.sh` is used to compile your project and produce artifacts, which are later injected into application containers for deployment.
- `command.sh` returns the space-separated command which is used as the ENTRYPOINT in your production containers. At run-time, this command will be executed inside the directory containing the unzipped artifacts produced by `compile.sh`

## Where are these buildpacks run?

As mentioned earlier, the scripts inside a buildpack (with the exception of `detect.sh`) are run inside special "build" containers spun up by Sous. This is advantageous over building things directly on your workstation, or inside your production images, for a number of reasons:

1. Compiling native code will be done inside the same OS and architecture that your code will be running on in production, so you will got OS- and architecture-compatible native binaries.
2. It means we can take advantage of any built-in caching that your build tool of choice does as standard.
3. It means you can keep your production images small and light, avoiding deploying all of your build-time dependencies, like npm, make, the go compiler, gcc, etc. into poduction. Deploying all this stuff into production is bad practice for many reasons, notably that it increases your attackable surface area, and slows down deployment by distributing unneccessary bloat.

A good illustration of these three points is NodeJS projects using NPM:

1. Even if you have never written a line of C or C++ in your life, if you're using Node with NPM, the chances are you will have been compiling C code that comes bundled with many of the modules available from NPM.
2. NPM also makes heavy use of local caching to speed up builds, which is a feature usually lost when building inside pristine production containers time and time again. Fortunately, Sous build containers are persistent (they get bigger and dirtier with age, ooh matron), so can you make use of that cache as it builds up over time, dramatically speeding up builds in some cases.
3. NodeJS apps commonly use many build and test frameworks like transpilers and mocking/unit testing libraries. Whilst you definitely do want to use these when writing your app, they can amount to hundreds of megabytes of bloat in some projects. This can seriously slow down deployments and app restarts if all that data needs to be sent to the compute node each time the app is started. Sous buildpacks help to avoid this bloat.

### The build environment

When the scripts from your buildpack are run, they will have an isolated copy of all the source code in the repository the user is building (details below). Your script will start off inside the same repository-relative directory that the user was in on their dev machine when they kicked off the build. This directory can be reached again later by:

    cd "$BASE_DIR/$REPO_DIR/$REPO_WORKDIR"

There are a number of other important environment variables you'll need to use in your buildpacks...

#### Environment Variables

- `$PROJ_NAME` is the name of your project
- `$PROJ_VERSION` is the closest semver git tag in the repository, it's in the form `major.minor.patch` if there is no semver git tag, it defaults to `0.0.0`
- `$PROJ_REVISION` is the Git commit SHA of your current checked-out commit
- `$PROJ_DIRTY` is either `YES` if you have uncommitted changes or new, non-ignored files in your repo, or `NO` otherwise.
- `$BASE_DIR` is the directory holding your the isolated copy of the source code repository. It is the directory one level down from your repository base directory.
- `$REPO_DIR` is the relative path of your repository's root directory (the one directly containing the isolated copy of the source code). It is typically just a single path component, like `my-project`. You can therefore go to your project's root directory by combining `$BASE_DIR` and `$REPO_DIR`
- `$REPO_WORKDIR` is the relative directory inside `$BASE_DIR/$REPO_DIR` where the user invoked the command from. If the user was in the root of the repository, this is set to the empty string, otherwise it's a relative directory path with no trailing slash.
- `$ARTIFACT_DIR` is probably the most important of these variables to understand. Your `compile.sh` script's job is to construct a mini file and directory hierarchy rooted at `$ARTIFACT_DIR`. Whatever ends up there will be treated as the artifact, and will be zipped up and plonked as-is inside your production container.

#### Isolated copy of the source code

In order to avoid making any changes to your source, Sous creates an isolated copy of your code inside a directory in the container. This copy is created by:

1. Mounting the root of your project (the directory containing the `.git` directory) inside the container.
2. Running `git ls-files --exclude-standard --others --cached` to obtain a list of all tracked and new files in your repository, and copying each file, into `$BASE_DIR/$REPO_DIR` inside the container, preserving directory hierarchy. 

This is very similar to Docker's built-in "send-context" action, except that it relies on your git index, and `.gitignore` file, and copies the files one-by-one instead of zipping up your entire working tree and sending that to the contianer, as Docker does by default. This also has the benefit that if you can build your code locally, you have probably got all the right things included in your git repository for others to also build it right after they clone.

