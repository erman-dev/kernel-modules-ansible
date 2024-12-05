import filter_plugins.insert_kernel_modules as cpu_filter
import yaml

yamlstring = """

name: amd_energy
git_repo: https://github.com/amd/amd_energy.git
force_build: true
# Example values from Xeon CPU
check_cpu_constraints:
    cpu_constraints:
    # No range
    - family: 0x06
      model: 0x86
    # family and model range closed
    - family:
        - range:
            start: 0x07
            end: 0x15
      model:
        - range:
            start: 0x00
            end: 0x15
    # Family and model range open
    - family:
        - range:
            start: 0x55
      model:
        - range:
            end: 0x11
"""

data = yaml.safe_load(yamlstring)

x = cpu_filter.check_cpu_constraints(data["check_cpu_constraints"])

print(x)
