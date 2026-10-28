<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins<ed@andexor.net>
-->

# How To Contribute

Thank you for your interest in contributing to this Andexor Network, Inc. project. This document outlines how to contribute to this project.

## Getting Started

Let's start with some housekeeping notes to be aware of before you begin contributing any features, fixes, etc. Read the following documents and be prepared to support them.

## Start a conversation

If this is your first contribution, send an email to ed@andexor.net with your idea. Let's discuss whether it is a good fit for Andexor Network, Inc.

## Code Of Conduct

Read the [Contributor Covenant 3.0 Code of Conduct](./CODE_OF_CONDUCT.md).

See also the [Contributor Covenant 3.0 Code of Conduct For Documentation](./CODE_OF_CONDUCT.adoc) for an alternate format suitable for use in documentation.

**All code commits are expected to sign-off on your acceptance of the Contributor Covenant 3.0 Code of Conduct.**

## Developer Certificate of Origin

This project complies with the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/).

See [DCO](./DCO) for details.

**All code commits are expected to sign-off on your acceptance of the Developer Certificate of Origin, Version 1.1.**

## License

Licensed under the [Apache License, Version 2.0](./LICENSE).

See [NOTICE](./NOTICE) for details.

**All code commits are furnished under the terms of the Apache License, Version 2.0.**

## Security Policy

Please take note of the [Security Policy](./SECURITY.md), which lists procedures for identifying and disclosing the discovery of potential security issues.

## Supported Operating Systems

In general, only open-source Linux distributions are supported for development, testing, and production use.

More specifically, it is preferred to always use the latest Ubuntu LTS release, though interim releases may also be used. Beta releases should generally be avoided. Ubuntu is preferred due to its wide support for AI and ML applications and its low memory overhead.

Other Linux distributions and other operating systems may have compatibility issues with dependencies arising from mis-matches between the development, testing, and production environments.

Whenever possible, the Alpine Linux distribution should also be supported, but only if it requires very little effort.

In Docker images the "scratch" base image should also be used whenever possible.

macOS can be used for some development, but is generally discouraged because the versions of dependencies will not always match those in Linux.

Mobile apps may be built for iOS, iPadOS, watchOS, visionOS, tvOS, or Android as needed.

All versions of Windows are expressly prohibited unless building a native app that requires it.

When testing API output, agent responses, web GUIs, etc., any OS can be used, though only the latest and one prior releases should be supported. This applies to end user production support as well.

## General Workflow

The following overview describes the general procedures for how to contribute to a repository.

1. Clone the repository.
1. Install build tools and project dependencies. See [setup.md](./setup.md) to get started.
1. Create an issue, or ask for one to be created for you. It should read like a user story. It should contain a Description heading and an Acceptance Criteria heading. It may also have a Technical Details heading if necessary. Explain what the feature or fix is and what it is supposed to do and why it should be done. Make a note of the issue number. You will need to reference it in your git commit message.
1. Create a new branch.
1. If you are adding or updating a feature, update the specification first, if there is one.
1. Add or update architecture documentation as needed, including
   - use case diagrams
   - mind map diagrams
   - state diagrams
   - activity diagrams
   - sequence diagrams
1. Make your changes.
1. Run thorough tests, including
   - unit tests
   - integration tests
   - security tests
   - performance tests
1. Include test plans, test data, and test results.
1. Include negative examples that expose the gap that this feature or fix is meant to resolve.
1. Include positive examples that demonstrate what something should look like after this issue is resolved and applied.
1. Update user documentation if needed.
1. If any maintenance procedures are required, first try to automate them. If that can not be done, then document the procedures.
1. Follow the PR Review Process described below.

## PR Review Process

1. Sync your branches with the GitHub server to minimize merge conflicts. There is no point in reviewing code that can not be merged. No one needs to deal with resolving merge conflicts except for the author of the PR.
1. **Be sure the use the `-s` flag with your `git commit` command to signal compliance with the documents listed above.**
1. **End the git commit message with `Closes #XX`, where XX is the issue number given earlier.** This will allow GitHub to automatically associate the PR with the issue and close the issue when the PR is merged. If this is a bug fix, it should say `Fixes` instead of `Closes`.
1. Push your branch to GitHub.
1. Issue a pull request.
1. Notify the maintainers that a PR is ready for review.

Be patient. It may take some time for your pull request to be reviewed and merged. Be aware that code may be automatically scanned for security vulnerabilities and checked for performance and other risk factors. The first few PRs from a new contributor may require several rounds of discussions before being accepted.

## Local Setup

Each project will have a common setup procedure that is appropriate for the language it is written in.

## Build and Serve

Each project will have common procedures for building and running it, based on the language it is written in.

## Code Standards

### Linting

Depending on what language the code is written in, it may provide a linter and instructions on how to use it.

### Formatting

Depending on what language the code is written in, it may provide a formatter and instructions on how to use it.

## Documentation Guidelines

For all projects, documentation is built with PlantUML and AsciiDoctor.

When contributing to the documentation:

- Start with a good specification addition if there is one
- Place new pages in appropriate sections
- Make sure each child page supports its parent page
- Keep content clear, concise, and technically accurate
- Know your audience, using details and summaries where appropriate
- Invest some time in writing and including UML diagrams
- Follow the existing file structure and naming conventions
- Include code examples where appropriate
- Test all links and code samples
- Use admonitions where helpful (NOTE, TIP, IMPORTANT, CAUTION, WARNING)

## AI Guidelines

It is assumed that you may use AI to generate code, fix bugs, or help with documentation. Here are some guidelines on how it should be used, how it should not be used, and what to look for when reviewing AI-generated content.

- Make sure code is readable.
- Make sure tests are included and at least 80% of tests pass.
- Make sure the code and tests support the spec.
- Think of as many edge cases as possible and plan to support them with input data validation and error handling.
- Do not accept AI slop text, audio, or video. If it sounds like AI wrote it, delete it and write it yourself.
- Do not accept auto-generated tests that technically pass, but have no real value.
- Follow established standard procedures for ensuring that real credentials, tokens, API keys, or other secrets are not leaked.

## Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for our commit messages and PR titles to automate releases. We enforce the following rules depending on which files are changed:

- **Specification (`docs(spec):`)**: Use for changes to the specification (`docs/specification.md`).
- **Documentation (`docs:`)**: Use for other documentation updates under `docs/`.
- **Features (`feat:`)**: Use for creating and maintaining features.
- **Fixes (`fix:`)**: Use for bug fixes.

## Configure Git for signoff

Use commands like these to configure Git so that you can use the signoff feature. Be sure to replace the "INSERT..." placeholder text with the appropriate values for you.

> `git config --global user.name "INSERT YOUR NAME HERE"`

> `git config --global user.email "INSERT YOUR EMAIL ADDRESS HERE"`

## signoff

**Be sure the use the `-s` flag with your `git commit` command to signal compliance with the following documents:**

- [Contributor Covenant 3.0 Code of Conduct](./CODE_OF_CONDUCT.md)
- [Developer Certificate of Origin, Version 1.1](./DCO)
- [Apache License, Version 2.0](./LICENSE)

When making a code commit, use a command like the following example:

> `git commit -s -m "INSERT GIT COMMIT MESSAGE HERE"`

Be sure to replace the "INSERT..." placeholder text with an appropriate Git commit message that summarizes the changes.

**Any pull request containing commits not signed off will not be approved to be merged.**
