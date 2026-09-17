-- hyprglass

if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass

	hg.config({
		default_theme = "dark",
		default_preset = "glass",
		tint_color = 0x8899aa22,

		brightness = 0.9,
		dark = { brightness = 0.82 },
		light = { adaptive_boost = 0.5 },

		layers = { enabled = true },
	})

	-- Layer surfaces: each call whitelists the namespace and configures it
	hg.layer("quickshell", { preset = "subtle", mask_threshold = 0.05 })
	hg.layer("swaync")
	hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
	hg.layer("debug-panel", { exclude = true })

	-- Presets
	hg.preset("clear", {
		glass_opacity = 0.8,
		blur_strength = 1.5,
		dark = { brightness = 0.7 },
		light = { brightness = 1.2 },
	})

	hg.preset("contrasted", {
		inherits = "high_contrast",
		contrast = 1.2,
		adaptive_dim = 1.5,
		dark = { tint_color = 0x02142aa9 },
	})

	hg.preset("glass", {
		blur_strength = 2.0,
		blur_iterations = 3,
		chromatic_aberration = 0.8,
		fresnel_strength = 0.8,
		edge_thickness = 0.08,
		tint_color = 0x111b301f,
		lens_distortion = 0.9,
		brightness = 1.0,
		contrast = 1.35,
		saturation = 0.65,
		vibrancy = 0.25,
		vibrancy_darkness = 0.65,
		adaptive_boost = 0.5,
	})

	hg.preset("apple", {
		blur_strength = 1.5,
		blur_iterations = 2,
		refraction_strength = 1,
		chromatic_aberration = 0.8,
		fresnel_strength = 0.5,
		specular_strength = 0.75,
		edge_thickness = 0.2,
		lens_distortion = 0.7,
		dark = {
			brightness = 0.82,
			contrast = 0.90,
			saturation = 0.80,
			vibrancy = 0.15,
			adaptive_dim = 0.4,
		},
		light = {
			brightness = 1.12,
			contrast = 0.92,
			saturation = 0.85,
			vibrancy = 0.12,
			adaptive_boost = 0.4,
		},
	})
end
