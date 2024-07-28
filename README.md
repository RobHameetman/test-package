<div id="top"></div>

# 📦 @rob.hameetman/test-package

<div align="center">
  <a href="https://github.com/RobHameetman/test-package">
    <img src="./.github/img/logo.png" alt="Logo" width="75" height="112">
  </a>
  <p align="center">
    <br />
    A package for testing configs
    <br />
    <br />
    <a href="#1-overview">Overview</a>
    ·
    <a href="#2-getting-started">Getting Started</a>
    ·
    <a href="#3-publishing">Publishing</a>
    ·
    <a href="#4-contact">Contact</a>
    ·
    <a href="#5-license">License</a>
  </p>
</div>

## §1: Overview

This is a test package used for testing the [@rob.hameetman/semantic-release-config](https://www.npmjs.com/package/@rob.hameetman/semantic-release-config)
package. It is used in a Docker container, which checks out this repo and then
copies the latest build artifact into `node_modules/`.

<p align="right"><a href="#top">⬆️ back to top</a></p>

## §2: Getting Started

Follow these steps to get the project up and running on your local machine:

### 1. Prerequisites

- Node v22+
- NPM v10+

### 2. Installation

```bash
git clone git@github.com:RobHameetman/test-package
cd test-package
```

### 3. Editor Configuration

For VSCode, save the following as `editor.code-workspace` in the project root
directory:

```json
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "editor.rulers": [
     80,
     120
    ],
    "files.autoSave": "onFocusChange",
  },
}
```

<p align="right"><a href="#top">⬆️ back to top</a></p>

## §3: Publishing

Creating and merging PRs will create new package versions that you can monitor
by vising the _Actions_ tab in Github.

### Channels

- `alpha`: Used for manual testing in other packages
- `beta`: Used for UAT and testing by external consumers
- `next`: Everything that will be included in the next major version release
- `pr-*`: Used for testing individual PRs

### Versioning

This project uses [SemVer](http://semver.org/) for versioning. For the versions
available, see the [tags on this repository](https://github.com/RobHameetman/test-package/tags).

Major versions should have a corresponding release in Github. Click
[here](https://github.com/RobHameetman/test-package/releases/new) to create a
new release once your version meets acceptance criteria.

A pre-release version will be published whenever you create a PR and incremented
as you update your changes. Once the PR is merged, a release version is created
automatically. This is handled with `semantic-release`. The versioning for your
PR has the following format by default

```Plaintext
<PR_PRERELEASE_TYPE>.<PR_NUMBER>.<COMMIT_SHA_SHORT>.<DATE_HASH>
```

By default, the `PR_PRERELEASE_TYPE` is `pr`, which yields something like the
following:

```Plaintext
v1.0.1-pr.1.b9e76bf8.20240728
```

This would be released to the channel `pr-1`, allowing you to install the latest
changes by running `npm i @rob.hameetman/test-package@pr-1`.

You can change the pre-release type by setting the `RELEASE_PR_PRERELEASE_TYPE`
environment variable. The entire pre-release ID and channel name can be changed
by setting `RELEASE_PR_PRERELEASE_PREID` and `PR_PRERELEASE_CHANNEL`
respectively.

<p align="right"><a href="#top">⬆️ back to top</a></p>

## §4: Contact

For inquiries and additional information, please reach out to:

**Rob Hameetman**  
_Front End Architect_ | Chicago, IL  
engineering@robhameetman.com

<p align="right"><a href="#top">⬆️ back to top</a></p>

## §5: License

Distributed under the MIT License.  
See the [LICENSE](LICENSE) file for details.

<p align="right"><a href="#top">⬆️ back to top</a></p>
