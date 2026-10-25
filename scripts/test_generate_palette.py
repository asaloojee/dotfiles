"""Run with: python3 -B -m unittest discover -s scripts -p 'test_*.py'."""

import json
import unittest
from unittest.mock import patch

import generate_palette as palette


class PaletteTests(unittest.TestCase):
    def test_reference_colors(self):
        for color, expected in (
            ("oklch(0 0 0)", "#000000"),
            ("oklch(1 0 0)", "#ffffff"),
            ("oklch(0.627955 0.257683 29.234)", "#ff0000"),
            ("oklch(0.226288 0.021374 280.487)", "#1a1b26"),
            ("oklch(0.718977 0.132159 264.202)", "#7aa2f7"),
        ):
            with self.subTest(color=color):
                self.assertEqual(palette.oklch_to_hex(color), expected)

    def test_gamut_mapping_preserves_lightness_and_hue(self):
        original = palette.linear_rgb
        with patch.object(palette, "linear_rgb", wraps=original) as convert:
            color = palette.oklch_to_hex("oklch(0.7 0.4 150)")
        self.assertRegex(color, r"^#[0-9a-f]{6}$")
        self.assertGreater(convert.call_count, 1)
        for call in convert.call_args_list:
            lightness, chroma, hue = call.args
            self.assertEqual((lightness, hue), (0.7, 150))
            self.assertLessEqual(chroma, 0.4)
        self.assertTrue(palette.in_gamut(original(*convert.call_args.args)))

    def test_aliases_and_nested_colors(self):
        colors = palette.resolve_palette(
            {
                "bg": "oklch(0 0 0)",
                "nested": {"bg": "@bg"},
                "list": ["@nested.bg", "NONE"],
            }
        )
        self.assertEqual(colors["list"], ["#000000", "NONE"])

    def test_invalid_input(self):
        for color in (
            "#ffffff",
            "oklch(1.1 0 0)",
            "oklch(0.5 -0.1 20)",
            "oklch(nan 0 0)",
            "oklch(0.5 0.1 400)",
        ):
            with self.subTest(color=color), self.assertRaises(ValueError):
                palette.oklch_to_hex(color)
        with self.assertRaises(ValueError):
            palette.resolve_palette({"a": "@b", "b": "@a"})
        with self.assertRaises(KeyError):
            palette.resolve_palette({"a": "@missing"})
        with self.assertRaises(TypeError):
            palette.resolve_palette({"a": 42})

    def test_generated_files_match_source(self):
        for path, expected in palette.outputs().items():
            self.assertEqual(path.read_text(), expected, str(path))

    def test_rex_and_neovim_use_identical_terminal_colors(self):
        generated = palette.outputs()
        colors = json.loads(generated[palette.RGB])
        lines = generated[palette.REX].splitlines()
        for index, name in enumerate(palette.ANSI):
            self.assertIn(f"palette = {index}={colors['terminal'][name]}", lines)
        self.assertIn(f"background = {colors['bg']}", lines)
        self.assertIn(f"foreground = {colors['fg']}", lines)


if __name__ == "__main__":
    unittest.main()
