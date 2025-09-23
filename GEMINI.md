## rules for creating release
* tag should be prefixed with 'v' like 'v1.0.3';
* when user ask to create release, check changelog, version number are correctly updated. if they aren't fix them.
* before createing pull request I need to check flutter analysis passes and apply `dart format .`. If those actions caused any changes I need to commit them then go on.
* before creating release I need to confirm every commits are pushed to remote origin.

