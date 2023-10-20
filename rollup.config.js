const eslint = require('@rbnlffl/rollup-plugin-eslint');
const commonjs = require('@rollup/plugin-commonjs');
const resolve = require('@rollup/plugin-node-resolve');
const copy = require('rollup-plugin-copy');
const { terser } = require('rollup-plugin-terser');
const typescript = require('rollup-plugin-typescript2');

const isProduction = process.env.NODE_ENV === 'production';
const isDevelopment = process.env.NODE_ENV === 'development';

const config = (format) => ({
	input: `${process.cwd()}/lib/index.ts`,
	output: {
		file: `${process.cwd()}/dist/index.${format === 'cjs' ? 'min' : 'esm'}.js`,
		exports: 'named',
		format,
		sourcemap: true,
	},
	external: ['react', '@guildeducationinc/recess'],
	plugins: [
		resolve({
			extensions: ['.ts', '.tsx', '.js', '.jsx'],
		}),
		eslint({
			extensions: ['js', 'jsx', 'ts', 'tsx', 'gql', 'graphql'],
			throwOnWarning: isProduction,
		}),
		typescript({
			rollupCommonJSResolveHack: false,
			clean: true,
		}),
		commonjs(),
		terser({
			output: {
				comments: false,
			},
		}),
		copy({
			targets: [
				{ src: 'README.md', dest: 'dist' },
				{ src: 'LICENSE', dest: 'dist' },
				{
					src: 'package.json',
					dest: 'dist',
					transform: (content) => {
						const pkgJson = JSON.parse(content.toString());

						delete pkgJson.scripts;
						delete pkgJson.devDependencies;
						delete pkgJson.engines;
						delete pkgJson.eslintConfig;
						delete pkgJson.prettier;
						delete pkgJson.stylelint;
						delete pkgJson.jest;
						delete pkgJson.postcss;
						delete pkgJson.release;

						/* if your project has side effects set sideEffects: true in your package.json */
						if ('sideEffects' in pkgJson && pkgJson.sideEffects === true) {
							delete pkgJson.sideEffects;
						} else {
							pkgJson.sideEffects = false;
						}

						return JSON.stringify(pkgJson, null, 2);
					},
				},
			],
		}),
	],
});

module.exports = [config('cjs'), config('es')];
