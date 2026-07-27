"""PEP 695 `type` statement fixtures for TypeAliasType tests.

This module exists separately from test_typenames.py because `type X = ...` is grammar,
not a runtime construct: `if sys.version_info >= (3, 12): type X = ...` is a SyntaxError
at compile time on Python < 3.12, so the containing module would never import. This
module is only imported by tests that are themselves guarded on Python >= 3.12.

It is also exempted from ruff's inferred `target-version` via
`[tool.ruff.per-file-target-version]` in pyproject.toml, since ruff would otherwise parse
it as Python 3.9 (from `requires-python`) and reject the `type` statement as invalid
syntax.
"""

import typing


class Inner:
    pass


type Simple = list[Inner]
type Gen[T] = list[T]
type NoneAlias = None
type JSON = typing.Union[str, int, list[JSON]]
