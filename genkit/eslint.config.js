// eslint.config.js
import globals from "globals";
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import pluginImport from "eslint-plugin-import";

export default tseslint.config(
    // 1. Global ignores
    {
        ignores: [
            "lib/**/*",
            "generated/**/*",
            "node_modules/",
            "*.config.js",
        ],
    },

    // 2. Base JS recommended rules
    js.configs.recommended,

    // 3. Base TypeScript setup (recommended typed rules, parser, etc.)
    ...tseslint.configs.recommendedTypeChecked,
    {
        languageOptions: {
            parserOptions: {
                project: ["tsconfig.json"],
                tsconfigRootDir: import.meta.dirname || process.cwd(),
            },
            globals: { ...globals.node, ...globals.es2021 }
        }
    },

    // REMOVE Block #4 (separate import plugin config) from your previous version

    // 4. SINGLE final block for ALL custom overrides for TS/JS files
    {
        files: ["**/*.{js,mjs,cjs,ts,tsx}"], // Target files

        // Define ALL required plugins for the rules below
        plugins: {
            '@typescript-eslint': tseslint.plugin, // Ensure TS plugin is defined here
            import: pluginImport,                 // Ensure import plugin is defined here
        },

        // Define ALL required settings for the plugins below
        settings: {
            'import/resolver': { // Settings for eslint-plugin-import
                typescript: true,
                node: true,
            },
        },

        // Define ALL rule overrides/settings together
        rules: {
            // --- Import Rules ---
            // Spread recommended sets if desired, or list rules manually
            ...pluginImport.configs.recommended.rules,
            ...pluginImport.configs.typescript.rules,
            "import/no-unresolved": "off",
            'import/no-named-as-default': 'warn',
            'import/no-named-as-default-member': 'warn',

            // --- TypeScript Rules ---
            // (Keep base rule disabling commented out/removed)
//            "@typescript-eslint/quotes": ["error", "double"], // Your rule causing issues
//            "@typescript-eslint/indent": ["error", 2], // Restore other TS rules too
//            "@typescript-eslint/object-curly-spacing": ["error", "always"], // Restore other TS rules too

            // --- Other Rules ---
            "max-len": [ "error", { code: 120, ignoreUrls: true, ignoreComments: true, ignoreRegExpLiterals: true, ignoreStrings: true, ignoreTemplateLiterals: true, } ],
            "require-jsdoc": "off",
            "valid-jsdoc": "off",

            // Any other overrides
        },
    }
); // End of tseslint.config wrapper