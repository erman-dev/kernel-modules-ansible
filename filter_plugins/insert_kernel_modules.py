#!/usr/bin/python3
import cpuinfo


def get_cpu_info():
    info = cpuinfo.get_cpu_info()
    return info["family"], info["model"]


def is_in_range(value, start, end):
    return start <= value <= end


def match_single_constraint(value, constraint):
    # Single value specified
    if isinstance(constraint, int):
        if value == constraint:
            return True

    # List of ranges specified
    elif isinstance(constraint, list):
        for item in constraint:
            range = item.get("range")
            if not range:
                raise ValueError(
                    "Constraints needs to be int or list of ranges!"
                )
            if is_in_range(value, range.get("start", 0), range.get("end", 255)):
                return True

    return False


def match_cpu_constraints(cpu_family, cpu_model, constraints):
    """Return True if CPU family and model are a match in any of the ranges."""
    family_match = False
    model_match = False

    for constraint in constraints:
        if match_single_constraint(cpu_family, constraint["family"]):
            family_match = True
        if match_single_constraint(cpu_model, constraint["model"]):
            model_match = True

    # Both model and family need to be a match to the constraints
    return family_match and model_match


def check_cpu_constraints(kernel_module):
    """Return True if the checks for constraints are positive and a match."""

    # Get list of constraints from kernel module data
    checks = kernel_module.get("cpu_constraints")

    # No constraints were defined
    if not checks:
        return True

    cpu_family, cpu_model = get_cpu_info()

    constraint_match = match_cpu_constraints(
        cpu_family, cpu_model, checks.get("cpu_inclusions", list()))
    exclusion_match = match_cpu_constraints(
        cpu_family, cpu_model, checks.get("cpu_exclusions", list()))

    if exclusion_match:
        return False

    return constraint_match


class FilterModule:
    def filters(self):
        return {
            "check_cpu_constraints": check_cpu_constraints
        }
