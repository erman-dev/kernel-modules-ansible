# Kernel module data spec

This part will describe details of what data need to be passed to insert_kernel_module role.

Example:
```yaml
kernel_modules:
  - name: amd_energy
    git_repo: https://github.com/amd/amd_energy.git
    git_repo_tag: b1033832b817e69f9df49a6a538d5fd2e1f10f6c
    force_build: true
    cpu_constraints:
      cpu_inclusions:
        - family: 0x19
          model: 0x55
      cpu_exclusions:
        - family: 0x20
          model: 0x56
    patches:
      - amd_energy_kernel_version.patch
```


| Attribute       | Required | Type | Description                                                                                        | Example                               |
| --------------- | -------- | ---- | -------------------------------------------------------------------------------------------------- | ------------------------------------- |
| name            | true     | str  | Name of the kernel module to be loaded                                                             | amd_energy                            |
| git_repo        | false    | str  | Repository from whichto build the off-tree module                                                  | https://github.com/amd/amd_energy.git |
| git_repo_tag    | false    | str  | Tag, branch or hash to checkout to when cloning git repo.                                          | develop                               |
| force_build     | false    | bool | Forces build in case the module is already built/loaded.                                           | True                                  |
| cpu_constraints | false    | dict | List of requirements that the CPU must satisfy on order for the module to be installed to the dost | example later                         |
| patches         | false    | list | List of names of patches from the files/ directory that will be applied to the fit repo.           | ["fix1.patch", "fix2.patch"]          |

## Example of cpu_constraints

cpu_constraints has two main keys - cpu_inclusions adn cpu_exclusions.
When cpu_inclusion is not met, the module will not be loaded/built.
When cpu_exclusion is met, the module will not be loaded/built. 
The same format of family/model is used for cpu_inclusions and for cpu_exclusions.

When no contraints are defined, the module will be loaded on all hosts!

```yaml
cpu_constraints:
  cpu_inclusions:
    # Single values
    - family: 0x19
      model: 0x3F
    # Closed ranges
    - family: 
        - range: 
            start: 0x19
            end: 0x55
      model:
        - range:
            start: 0x10
            end: 0x1F
        - range:
            start: 0xA0
            end: 0xAF
    # Open ranges
    - family:
        - range:
            end: 0x04
      model:
        - range:
            start: 0x0F
```