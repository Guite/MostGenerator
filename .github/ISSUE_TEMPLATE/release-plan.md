---
name: Release Plan
about: internal issue template used for preparing releases
title: Release ModuleStudio VERSION
labels: 
assignees: 'Guite'

---

## Prerequisites

- [ ] Close milestone
- [ ] Update changelog providing a release date
- [ ] Wait until _Help_ and _Product_ builds have been finished
- [ ] Start _"Product build"_ [here](https://github.com/Guite/MostProduct/)
- [ ] Start _"Release step 1 - Translation pack"_ [here](https://github.com/Guite/MostProduct/)
- [ ] Start _"Release step 2 - Create release"_ [here](https://github.com/Guite/MostProduct/)
- [ ] Review
  - [ ] Verify `stable` repository is updated
  - [ ] Check the [release page at GitHub](https://github.com/Guite/MostGenerator/releases)
      - [ ] Update link to changelog (to let it point to the correct section)
- [ ] Review release assets, try to download and unpack them

## Spread the word

- [ ] Provide news article at <https://modulestudio.de>
- [ ] Create blog post at <https://get-the-most.de>
  - [ ] Forwarded to Xing
- [ ] Post on Facebook
- [ ] Post on #mdsd chanel in Symfony slack

## Start next iteration

- [ ] Increment version number in all components
- [ ] Add new version to the changelog.
- [ ] Create [issue milestone](https://github.com/Guite/MostGenerator/milestones) if needed
