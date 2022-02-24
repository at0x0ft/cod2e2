# Maintenance Tools

## Description

Cloning (deriving) language development environment template and checking each file difference tools

## Maintenance Scripts

### Deriving

- [`derive_template.sh`](./derive_template.sh): Cloning template and registering destination path

### Checking

- [`check_internal_difference.sh`](./check_internal_difference.sh): Checking the difference between [`base`](../base/) templates and derived each language template (inside [`languages`](../languages/) directory)
- [`check_external_difference.sh`](./check_external_difference.sh): Checking the difference between each language template (inside [`languages`](../languages/) directory) and its derived template (usually placed outside of this repository)

### Note

- Detailed search file lists are registered in simple plain text file (`seach_files`) inside [`internal`](./compare_list/internal/) or [`external/*`](./compare_list/external/) directory.
- Internal original and derived path pair lists are registered in simple plain text file (`./compare_list/internal/original_derived_pairs`) .
- External derived path lists are registered in `./compare_list/external/*/derived` file. **This file is ignored by Git** (because it contains raw path data) . So you should be careful to lose its data when delete and clone this repo again.
