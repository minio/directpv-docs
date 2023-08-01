# MinIO's DirectPV Documentation

The DirectPV docs use [Hugo](https://www.gohogo.io) to generate static HTML pages.

- [MinIO's DirectPV Documentation](#minios-directpv-documentation)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Update Theme from Upstream Repository](#update-theme-from-upstream-repository)
  - [Build Preview](#build-preview)
  - [Build for production](#build-for-production)
  - [Style](#style)
    - [Markup](#markup)
    - [Style Guides](#style-guides)
    - [Spelling](#spelling)
    - [Code Blocks](#code-blocks)
  - [Shortcodes](#shortcodes)
    - [Internal linking](#internal-linking)
    - [Components (Tabs, Admonitions, Cards, etc.)](#components-tabs-admonitions-cards-etc)
  - [Frontmatter](#frontmatter)

## Prerequisites

- Any [operating system that Hugo supports](https://gohugo.io/installation/)
- [nodejs](https://nodejs.org/en/download/package-manager/) 16.9.x or later
 
  **Note**: Ubuntu ships with older versions of Node that Hugo does not support. Use [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) to install a later version.
- [Node Package Manager](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) installed (8.5.0 or later)
- [Hugo installed](https://gohugo.io/installation/) (0.110.0 or later)

## Setup

1. Clone this repository
2. cd to the directory (`cd directpv-docs`)
3. Initialize the theme directory submodule

   ```
   git submodule update --init --recursive
   ```

4. `cd themes/kes-doc-theme`
5. `npm install`
6. `npm build`
7. `cd ../../`
  
## Update Theme from Upstream Repository

The theme we use in the docs is hosted and maintained in a separate, private repository.
We use a the git submodule functionality to include it here.
After updating the theme, re-install node packages and then re-build the theme assets.

To pull new updates to the theme from the upstream repository, run the following:

```
git submodule update --recursive --remote
cd themes/hugo-docs-theme
npm install
npm run build
cd ../../
git add . && git commit -m "Update theme"
```

## Build Preview

You can launch a live preview of the site as you work.

1. From your terminal in the repository folder, run

   ```shell
   hugo server
   ```

2. In your browser, go to `localhost:1313/docs/directpv/`

## Build for production

To build the site for production or to upload to the staging server:

1. Run

   ```shell
   hugo
   ```

2. Contents go to the `/public` directory in the repo folder.

## Style

### Markup

We write in [Goldmark Markdown](https://github.com/yuin/goldmark/) as extended by [Hugo shortcodes](https://gohugo.io/content-management/shortcodes/) and our own [shortcodes](#shortcodes).

Goldmark is fully [Commonmark](https://commonmark.org/help/) compliant.

### Style Guides

MinIO uses an internal style guide.
Allow maintainers to modify your branch when you submit your PR so that we can adjust for internal style consistencies.

Otherwise, follow these resources in order of preference:

1. [MongoDB Style Guide](https://www.mongodb.com/docs/meta/style-guide/quickstart/)
2. [ASD-STE-100 Simplified Technical English](https://asd-ste100.org/STE_downloads.html#features16-x)
3. [Google Developer Style Guide](https://developers.google.com/style/)

### Spelling

We write in American English, using [Merriam Webster's online dictionary](https://www.merriam-webster.com/) as the standard spelling reference.

### Code Blocks

To add a copy button to a code block, add `{.copy}` after the language format.

For example

```md
```yaml {.copy}
tls:
  key:      ./server.key   # Path to the TLS private key
  cert:     ./server.cert  # Path to the TLS certificate
  password: ""             # An optional password to decrypt the TLS private key
```

The code block *must* have a valid language type for the copy function to work.

## Shortcodes

Hugo uses shortcodes to extend what is normally available with Markdown.

### Internal linking

To link to another page within the docs, use the following format.

```Markdown
[link text]({{< relref "path/to/page/#heading" >}})
```

### Components (Tabs, Admonitions, Cards, etc.)

Refer to `themes/hugo-docs-theme/README.md`.

## Frontmatter

We use YAML-formatted [front matter](https://gohugo.io/content-management/front-matter/).

<!---
We need to implement cascading front matter.
See https://gohugo.io/content-management/front-matter/#front-matter-cascade.
-->

Pages should have at least the following front matter tokens:

```yaml
---
title: <Page Title>
date: YYYY-MM-DD ## date of file creation
lastmod: :git ## this is retrieved from git and should not be modified
draft: false ## set to true if the document is not yet ready for publication
tableOfContents: true ## creates a right-side page navigation TOC, set to `false` if not needed
---
```
