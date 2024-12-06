import filter_plugins.insert_kernel_modules as cpu_filter
import yaml

cpu_family = 0x06
cpu_model = 0x86

with open('./group_vars/all.yml', 'r') as file:
    data = yaml.safe_load(file)

for module in data["kernel_modules"]:
  result = cpu_filter.check_cpu_constraints(module, cpu_family, cpu_model)
  print(f"Module {module['name']} cpu inclusion check: {result}")
